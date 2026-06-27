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
      config = {
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

          currentSystem =
            mkSchema
              ''
                ${perSystemDoc "currentSystem"}

                Only available in impure mode.
              ''
              (output: {
                what = "perSystem flake-parts configuration for ${output.allModuleArgs.system}";
              });

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
        };
      };
    };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-debugSchemas";
        component = with local.inputs.self.components; nixology.core.debugSchemas;
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
            component.module
          ];
        };
      };
    in
    [
      evalEnabled.config.flake.exportedSchemas.allSystems
      evalEnabled.config.flake.exportedSchemas.currentSystem
      evalEnabled.config.flake.exportedSchemas.debug
    ]
  );
in
{
  imports = [
    check
    implementation
  ];

  flake.components = {
    nixology.core.debugSchemas = {
      inherit implementation;

      dependencies = with local.inputs.self.components; [
        nixology.core.exportedSchemas
      ];

      meta = {
        description = "Exported schemas for debugging flake-parts";
        shortDescription = "exported schemas for debugging flake-parts";
      };
    };
  };
}
