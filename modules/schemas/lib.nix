{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  inherit (local.lib.components) evalComponent;

  inherit (local.config.partitions.schemas.extraInputs) flake-schemas;

  inherit (flake-schemas.lib) mkChildren;

  implementation =
    { ... }@module:
    {
      flake.exportedSchemas = {
        lib = {
          version = 1;

          doc = ''
            The lib flake output provides a collection of functions.
          '';

          inventory =
            let
              recurse =
                library:
                mkChildren (
                  builtins.mapAttrs (
                    name: value:
                    if builtins.isAttrs value then
                      recurse value
                    else if builtins.isFunction value then
                      {
                        what = "library function";
                        # Make `nix flake check` enforce our naming convention.
                        evalChecks.camelCase = builtins.match "^[a-z][a-zA-Z]*$" name == [ ];
                      }
                    else
                      {
                        what = "library value";
                      }
                  ) library
                );
            in
            recurse;
        };
      };

      perSystem = { pkgs, ... }: {
        checks =
          let
            inherit (evalComponent { inherit (module) inputs; } nixology.schemas.lib) config;
          in
          {
            nixology-schemas-lib = pkgs.runCommandLocal "checks" {
              check_flake_exportedSchemas_lib = builtins.seq config.flake.exportedSchemas.lib "ok";
            } "touch $out";
          };
      };
    };
in
{
  imports = [
    implementation
  ];

  flake.components = {
    nixology.schemas.lib = {
      inherit implementation;

      dependencies = [
        nixology.core.exportedSchemas
      ];

      meta = {
        description = "Exported schemas for the lib flake output.";
        shortDescription = "exported schemas for the lib flake output";
      };
    };
  };
}
