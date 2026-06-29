local@{ ... }:
let
  inherit (local.inputs.self.components) nixology;

  inherit (local.lib)
    isAttrs
    mkDefault
    mkOption
    optionalString
    ;

  inherit (local.lib.types)
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

  moduleLocation = "${local.inputs.self.outPath}/flake.nix";

  implementation =
    module@{ ... }:
    let
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
          args@{ name, ... }:
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
                      default = args.name;
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
                  local.lib.throwIfNot (local.config.flakeref != null)
                    "nixology: `flakeref` must be set before components can be used. Add `flakeref = \"github:your-org/your-repo\";` to your flake module."
                    {
                      key =
                        "${local.config.flakeref}#components.${domain}.${subdomain}.${args.config.meta.name}"
                        + optionalString (args.config.meta.version != null) ".${args.config.meta.version}";

                      imports = [
                        args.config.implementation
                      ]
                      ++ map (dependency: dependency.module) args.config.dependencies;

                      _class = "flake";
                      _file = "${moduleLocation}#components.${domain}.${subdomain}.${args.config.meta.name}";
                    };
              };
            };

            config = {
              meta.name = mkDefault args.name;
            };
          }
        );

      subdomainType =
        domain:
        submodule (
          args@{ name, ... }:
          {
            freeformType = lazyAttrsOf (componentType {
              inherit domain;
              subdomain = args.name;
            });
          }
        );

      domainType = submodule (
        args@{ name, ... }:
        {
          freeformType = lazyAttrsOf (subdomainType args.name);
        }
      );
    in
    {
      options.flake.components = mkOption {
        type = lazyAttrsOf domainType;
        default = { };
        description = "A set of reusable components.";
      };

      config.flake.schemas = { inherit (local.config.flake.exportedSchemas) components; };
    };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-components";
        component = nixology.core.components;
        extraChecks = ({ eval, ... }: [ eval.config.flake.components ]);
        inherit (module) config;
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

      dependencies = [
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
