local@{ ... }:
let
  implementation =
    let
      inherit (local.config.partitions.schemas.extraInputs.flake-schemas.lib) mkChildren;

      version = 1;

      mkSchema = doc: inventory: {
        inherit version doc inventory;
      };

      perSystemDoc = target: ''
        The `${target}` flake output provides the perSystem flake-parts configuration.

        An attribute set consisting of the `perSystem` attributes, plus the extra
        attributes `_module`, `config`, `options`, `extendModules`.

        N.B. these are not part of the `config` parameter, but are merged in for
        debugging convenience.
      '';
    in
    {
      imports = [
        "${local.inputs.flake-parts}/modules/debug.nix"
      ];

      config = {
        debug = true;

        flake.schemas = { inherit (local.config.flake.exportedSchemas) allSystems debug currentSystem; };

        flake.exportedSchemas = {
          allSystems =
            mkSchema
              ''
                The `allSystems` flake output provides the perSystem flake-parts configuration.

                An attribute set of configured systems, each consisting of the `perSystem`
                attributes, plus the extra attributes `_module`, `config`, `options`,
                `extendModules`.

                N.B. these are not part of the `config` parameter, but are merged in for
                debugging convenience.
              ''
              (
                output:
                mkChildren (
                  builtins.mapAttrs (_name: _value: {
                    what = "perSystem flake-parts configuration";
                  }) output
                )
              );

          debug =
            mkSchema
              ''
                The `debug` flake output provides the top-level flake-parts configuration.

                An attribute set consisting of the `config` attributes, plus the extra
                attributes `_module`, `config`, `options`, `extendModules`.

                N.B. these are not part of the `config` parameter, but are merged in for
                debugging convenience.
              ''
              (_output: {
                what = "top-level flake-parts configuration";
              });

          currentSystem =
            mkSchema
              ''
                ${perSystemDoc "currentSystem"}

                Only available in impure mode.
              ''
              (output: {
                what = "perSystem flake-parts configuration for ${output.allModuleArgs.system}";
              });
        };
      };
    };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-debug";
        component = with local.inputs.self.components; nixology.core.debug;
        inherit extraChecks;
        inherit (module) config;
      };
    };

  extraChecks = (
    { evalComponent, component, ... }:
    let
      evalEnabled = evalComponent {
        module = {
          imports = [
            { debug = true; }
            component.module
          ];
        };
      };
    in
    [
      evalEnabled.config
      evalEnabled.config.allSystems
      evalEnabled.config.debug
    ]
  );
in
{
  imports = [
    check
    implementation
  ];

  flake.components = {
    nixology.core.debug = {
      inherit implementation;

      dependencies = with local.inputs.self.components; [
        nixology.core.flake
        nixology.core.perSystem
        nixology.core.schemas
      ];

      meta = {
        description = "Expose debug attributes for the flake.";
        shortDescription = "expose debug attributes for the flake";
      };
    };
  };
}
