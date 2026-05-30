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
      perSystem =
        { pkgs, ... }:
        let
          schemasComponent = with inputs.self.components; nixology.core.schemas;

          evalSchemas = config.flake.lib.evalComponent { inherit inputs; } schemasComponent;
        in
        {
          checks.core-schemas = pkgs.runCommandLocal "core-schemas-check" { } ''
            : ${builtins.seq evalSchemas.config "ok"}
            : ${builtins.seq evalSchemas.config.flake.schemas.schemas "ok"}
            touch $out
          '';
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
