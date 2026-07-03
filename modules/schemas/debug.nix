{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  inherit (local.lib.components) evalComponent;

  implementation =
    { ... }@module:
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

        perSystem = { pkgs, ... }: {
          checks =
            let
              inherit (evalComponent { inherit (module) inputs; } nixology.schemas.debug) config;
            in
            {
              nixology-schemas-debug = pkgs.runCommandLocal "checks" {
                check_flake_exportedSchemas_allSystems = builtins.seq config.flake.exportedSchemas.allSystems "ok";
                check_flake_exportedSchemas_currentSystem = builtins.seq config.flake.exportedSchemas.currentSystem "ok";
                check_flake_exportedSchemas_debug = builtins.seq config.flake.exportedSchemas.debug "ok";
              } "touch $out";
            };

        };
      };
    };
in
{
  imports = [
    implementation
  ];

  flake.components = {
    nixology.schemas.debug = {
      inherit implementation;

      dependencies = [
        nixology.core.exportedSchemas
      ];

      meta = {
        description = "Exported schemas for flake-parts debug attributes";
        shortDescription = "exported schemas for flake-parts debug attributes";
      };
    };
  };
}
