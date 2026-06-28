local@{ ... }:
let
  inherit (local.lib)
    mkOption
    types
    ;

  inherit (types)
    anything
    lazyAttrsOf
    ;

  inherit (local.config.partitions.schemas.extraInputs) flake-schemas;

  implementation = {
    options.flake.schemas = mkOption {
      type = lazyAttrsOf (lazyAttrsOf anything);
      default = { };
      description = "Schemas for flake output types.";
    };

    config.flake.schemas = {
      inherit (flake-schemas.exportedSchemas) schemas;
    };
  };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-schemas";
        component = with local.inputs.self.components; nixology.core.schemas;
        extraChecks = ({ eval, ... }: [ eval.config.flake.schemas.schemas ]);
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
    nixology.core.schemas = {
      inherit implementation;

      dependencies = with local.inputs.self.components; [
        nixology.core.flake
      ];

      meta = {
        description = "Flake schemas used by this flake.";
        shortDescription = "flake schemas used by this flake";
      };
    };
  };
}
