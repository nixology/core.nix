local@{ ... }:
let
  inherit (local.config.partitions.schemas.extraInputs) flake-schemas;

  implementation =
    with local.lib;
    with types;
    {
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
        component = with local.inputs.self.components; nixology.core.exportedSchemas;
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

      dependencies = with local.inputs.self.components; [
        nixology.core.schemas
      ];

      meta = {
        description = "Used to define flake schemas that you\nintend for other flakes to use.";
        shortDescription = "exported flake schemas";
      };
    };
  };
}
