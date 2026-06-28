local@{ ... }:
let
  inherit (local.inputs.self.components) nixology;

  inherit (local.lib)
    mkOption
    types
    ;

  inherit (types)
    lazyAttrsOf
    anything
    ;

  inherit (local.config.partitions.schemas.extraInputs) flake-schemas;

  implementation = {
    options.flake.exportedSchemas = mkOption {
      type = lazyAttrsOf (lazyAttrsOf anything);
      default = { };
      description = "Schemas for other flakes to use.";
    };

    config.flake.schemas = {
      inherit (flake-schemas.exportedSchemas) exportedSchemas;
    };
  };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-exportedSchemas";
        component = nixology.core.exportedSchemas;
        extraChecks = ({ eval, ... }: [ eval.config.flake.schemas.exportedSchemas ]);
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
    nixology.core.exportedSchemas = {
      inherit implementation;

      dependencies = [
        nixology.core.schemas
      ];

      meta = {
        description = "Flake schemas exported for other flakes to use.";
        shortDescription = "flake schemas exported for other flakes to use";
      };
    };
  };
}
