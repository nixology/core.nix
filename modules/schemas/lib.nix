local@{ ... }:
let
  inherit (local.config.partitions.schemas.extraInputs) flake-schemas;

  implementation = {
    flake.exportedSchemas = {
      lib = {
        version = 1;
        doc = ''
          The lib flake output provides a collection of functions.
        '';
        inventory =
          let
            inherit (flake-schemas.lib) mkChildren;
          in
          output:
          mkChildren (
            builtins.mapAttrs (_name: value: {
              what = if builtins.isFunction value then "library function" else "library value";
            }) output
          );
      };
    };
  };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-schemas-lib";
        component = with local.inputs.self.components; nixology.schemas.lib;
        extraChecks = { eval, ... }: [ eval.config.flake.exportedSchemas.lib ];
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
    nixology.schemas.lib = {
      inherit implementation;

      dependencies = with local.inputs.self.components; [
        nixology.core.exportedSchemas
      ];

      meta = {
        description = "Exported schemas for the lib flake output.";
        shortDescription = "exported schemas for the lib flake output";
      };
    };
  };
}
