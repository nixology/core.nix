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
                configs:
                mkChildren (
                  builtins.mapAttrs (system: config: {
                    what = "flake-parts perSystem config";
                  }) configs
                )
              );

          currentSystem =
            mkSchema
              ''
                ${perSystemDoc "currentSystem"}

                Only available in impure mode.
              ''
              (config: {
                what = "flake-parts perSystem config for ${config.allModuleArgs.system}";
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
              (config: {
                what = "flake-parts top-level configuration";
              });
        };
      };
    };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-schemas-debug";
        component = with local.inputs.self.components; nixology.schemas.debug;
        inherit extraChecks;
        inherit (module) config;
      };
    };

  extraChecks = (
    { eval, ... }:
    [
      eval.config.flake.exportedSchemas.allSystems
      eval.config.flake.exportedSchemas.currentSystem
      eval.config.flake.exportedSchemas.debug
    ]
  );
in
{
  imports = [
    check
    implementation
  ];

  flake.components = {
    nixology.schemas.debug = {
      inherit implementation;

      dependencies = with local.inputs.self.components; [
        nixology.core.exportedSchemas
      ];

      meta = {
        description = "Exported schemas for flake-parts debug attributes";
        shortDescription = "exported schemas for flake-parts debug attributes";
      };
    };
  };
}
