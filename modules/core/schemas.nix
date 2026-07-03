{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  inherit (local.lib)
    mkOption
    ;

  inherit (local.lib.types)
    anything
    lazyAttrsOf
    ;

  inherit (local.config.partitions.schemas.extraInputs) flake-schemas;

  implementation =
    { ... }@module:
    {
      options = {
        flake.schemas = mkOption {
          type = lazyAttrsOf (lazyAttrsOf anything);
          default = { };
          description = "Schemas for flake output types.";
        };
      };

      config = {
        flake.schemas = {
          inherit (flake-schemas.exportedSchemas) schemas;
        };

        perSystem = { pkgs, ... }: {
          checks =
            let
              inherit (local.config.flake.lib) evalComponent;
              inherit (evalComponent { inherit (module) inputs; } nixology.core.schemas) config;
            in
            {
              nixology-core-schemas = pkgs.runCommandLocal "checks" {
                check_flake_schemas_schemas = builtins.seq config.flake.schemas.schemas "ok";
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
    nixology.core.schemas = {
      inherit implementation;

      dependencies = [
        nixology.core.flake
      ];

      meta = {
        description = "Flake schemas used by this flake.";
        shortDescription = "flake schemas used by this flake";
      };
    };
  };
}
