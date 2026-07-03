{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  inherit (local.lib)
    isAttrs
    mapAttrs
    ;

  inherit (local.lib.components) evalComponent;

  inherit (local.config.partitions.schemas.extraInputs) flake-schemas;

  inherit (flake-schemas.lib) mkChildren;

  implementation =
    { ... }@module:
    {
      config = {
        flake.exportedSchemas = {
          components = {
            version = 1;

            doc = "The `components` flake output provides importable components.";

            inventory =
              let
                recurse =
                  components:
                  mkChildren (
                    mapAttrs (
                      name: value:
                      if isAttrs value && value ? module then
                        {
                          what =
                            if value.meta.shortDescription != null then
                              "component (${value.meta.shortDescription})"
                            else
                              "component attribute";
                        }
                      else
                        recurse value
                    ) components
                  );
              in
              recurse;
          };
        };

        perSystem = { pkgs, ... }: {
          checks =
            let
              inherit (evalComponent { inherit (module) inputs; } nixology.schemas.components) config;
            in
            {
              nixology-schemas-components = pkgs.runCommandLocal "checks" {
                check_flake_exportedSchemas_components = builtins.seq config.flake.exportedSchemas.components "ok";
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
    nixology.schemas.components = {
      inherit implementation;

      dependencies = [
        nixology.core.exportedSchemas
      ];

      meta = {
        description = "Exported schemas for nixology component attributes.";
        shortDescription = "exported schemas for nixology component attributes";
      };
    };
  };
}
