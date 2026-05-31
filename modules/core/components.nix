{ config, inputs, ... }:
let
  inherit (config.partitions.schemas.extraInputs) flake-schemas;

  moduleLocation = "${inputs.self.outPath}/flake.nix";

  rootConfig = config;

  implementation =
    { config, lib, ... }:
    let
      inherit (lib)
        isAttrs
        mapAttrs
        mkDefault
        mkOption
        optionalString
        types
        ;

      inherit (types)
        addCheck
        deferredModule
        lazyAttrsOf
        listOf
        nonEmptyStr
        nullOr
        raw
        submodule
        unique
        ;

      undeclaredMetaMessage = ''
        No option has been declared for this attribute, so its definitions can't be merged automatically.
        Possible solutions:
          - Load a module that defines this attribute
          - Declare an option for this attribute
          - Make sure the attribute is spelled correctly
          - Define the value only once, with a single definition in a single module
      '';

      componentRefType = addCheck raw (value: isAttrs value && value ? module);

      componentType =
        { domain, subdomain }:
        submodule (
          { name, config, ... }:
          {
            options = {
              dependencies = mkOption {
                type = listOf componentRefType;
                default = [ ];
                description = "A list of other components that this component depends on.";
              };

              meta = mkOption {
                type = nullOr (submodule {
                  options = {
                    name = mkOption {
                      type = nonEmptyStr;
                      default = name;
                      description = "The name of the component.";
                    };

                    description = mkOption {
                      type = nullOr nonEmptyStr;
                      default = null;
                      description = "A description of the component.";
                    };

                    shortDescription = mkOption {
                      type = nullOr nonEmptyStr;
                      default = null;
                      description = "A short description of the component.";
                    };

                    version = mkOption {
                      type = nullOr nonEmptyStr;
                      default = null;
                      description = "The version of the component.";
                    };
                  };

                  freeformType = lazyAttrsOf (
                    unique {
                      message = undeclaredMetaMessage;
                    } raw
                  );
                });

                default = { };
                description = "Metadata about the component.";
              };

              implementation = mkOption {
                type = deferredModule;
                description = "The module defining this component.";
              };

              module = mkOption {
                type = deferredModule;
                readOnly = true;
                description = "The fully resolved component module including dependencies.";
                apply =
                  _:
                  lib.throwIfNot (rootConfig.flakeref != null)
                    "nixology: `flakeref` must be set before components can be used. Add `flakeref = \"github:your-org/your-repo\";` to your flake module."
                    {
                      key =
                        "${rootConfig.flakeref}#components.${domain}.${subdomain}.${config.meta.name}"
                        + optionalString (config.meta.version != null) ".${config.meta.version}";

                      imports = [ config.implementation ] ++ map (dependency: dependency.module) config.dependencies;

                      _class = "flake";
                      _file = "${moduleLocation}#components.${domain}.${subdomain}.${config.meta.name}";
                    };
              };
            };

            config = {
              meta.name = mkDefault name;
            };
          }
        );

      subdomainType =
        domain:
        submodule (
          { name, ... }:
          {
            freeformType = lazyAttrsOf (componentType {
              inherit domain;
              subdomain = name;
            });
          }
        );

      domainType = submodule (
        { name, ... }:
        {
          freeformType = lazyAttrsOf (subdomainType name);
        }
      );
    in
    {
      options.flake.components = mkOption {
        type = lazyAttrsOf domainType;
        default = { };
        description = "A set of reusable components.";
      };

      config.flake.schemas.components = {
        version = 1;
        doc = "The `components` flake output provides importable components.";

        inventory =
          let
            inherit (flake-schemas.lib) mkChildren;

            recurse =
              attrs:
              mapAttrs (
                _: value:
                if isAttrs value && value ? module then
                  {
                    what =
                      if value.meta.shortDescription != null then
                        "component (${value.meta.shortDescription})"
                      else
                        "component";
                  }
                else
                  {
                    children = recurse value;
                  }
              ) attrs;
          in
          output:
          mkChildren (
            mapAttrs (_: value: {
              children = recurse value;
            }) output
          );
      };
    };

  check =
    { config, ... }:
    {
      perSystem = config.flake.lib.mkComponentCheck {
        name = "nixology-core-components";
        component = with inputs.self.components; nixology.core.components;
        inherit config;
      };
    };
in
{
  imports = [
    check
    implementation
  ];

  flake.components = {
    nixology.core.components = {
      inherit implementation;

      dependencies = with inputs.self.components; [
        nixology.core.schemas
      ];

      meta = {
        shortDescription = "reusable component system for flake modules";
        description = ''
          Provides a reusable component system for flake modules organized into a
          structured domain.subdomain.name hierarchy with support for dependencies
          and metadata.
        '';
      };
    };
  };
}
