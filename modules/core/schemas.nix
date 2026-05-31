{ config, inputs, ... }:
let
  inherit (config.partitions.schemas.extraInputs) flake-schemas;

  implementation =
    { lib, ... }:
    {
      options.flake.schemas = lib.mkOption {
        type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.anything);
        default = { };
        description = "Schemas for flake output types.";
      };

      config.flake.schemas = {
        inherit (flake-schemas.schemas) schemas;
      };
    };

  check =
    { config, ... }:
    {
      perSystem = config.flake.lib.mkComponentCheck {
        name = "nixology-core-schemas";
        component = with inputs.self.components; nixology.core.schemas;
        extraChecks = ({ eval, ... }: [ eval.config.flake.schemas.schemas ]);
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
    nixology.core.schemas = {
      inherit implementation;

      dependencies = with inputs.self.components; [
        nixology.core.flake
      ];

      meta = {
        description = "Provide flake schemas support and expose the flake-schemas schema.";
        shortDescription = "flake schemas";
      };
    };
  };
}
