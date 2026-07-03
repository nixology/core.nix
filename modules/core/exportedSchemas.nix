{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  inherit (local.lib.components) evalComponent;

  implementation =
    let
      inherit (local.lib) mkOption;
      inherit (local.lib.types) lazyAttrsOf anything;
      inherit (local.config.partitions.schemas.extraInputs) flake-schemas;
    in
    { ... }@module:
    {
      options = {
        flake.exportedSchemas = mkOption {
          type = lazyAttrsOf (lazyAttrsOf anything);
          default = { };
          description = "Schemas for other flakes to use.";
        };
      };

      config = {
        flake.schemas = {
          inherit (flake-schemas.exportedSchemas) exportedSchemas;
        };

        perSystem = { pkgs, ... }: {
          checks =
            let
              inherit (evalComponent { inherit (module) inputs; } nixology.core.exportedSchemas) config;
            in
            {
              nixology-core-exportedSchemas = pkgs.runCommandLocal "checks" {
                check_flake_schemas_exportedSchemas = builtins.seq config.flake.schemas.exportedSchemas "ok";
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
    nixology.core.exportedSchemas = {
      inherit implementation;

      dependencies = [
        nixology.core.perSystem
        nixology.core.schemas
      ];

      meta = {
        description = "Flake schemas exported for other flakes to use.";
        shortDescription = "flake schemas exported for other flakes to use";
      };
    };
  };
}
