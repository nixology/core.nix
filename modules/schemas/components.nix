local@{ ... }:
let
  inherit (local.config.partitions.schemas.extraInputs) flake-schemas;
  inherit (flake-schemas.lib) mkChildren;

  implementation = with local.lib; {
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
    };
  };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-schemas-components";
        component = with local.inputs.self.components; nixology.schemas.components;
        extraChecks = ({ eval, ... }: [ eval.config.flake.exportedSchemas.components ]);
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
    nixology.schemas.components = {
      inherit implementation;

      dependencies = with local.inputs.self.components; [
        nixology.core.exportedSchemas
      ];

      meta = {
        description = "Exported schemas for nixology component attributes.";
        shortDescription = "exported schemas for nixology component attributes";
      };
    };
  };
}
