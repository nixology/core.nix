local@{ ... }:
let
  inherit (local.config.partitions.schemas.extraInputs) flake-schemas;

  implementation = with local.lib; {
    config = {
      flake.exportedSchemas = {
        components = {
          version = 1;
          doc = "The `components` flake output provides importable components.";

          inventory =
            let
              inherit (flake-schemas.lib) mkChildren;

              recurse =
                attrs:
                mapAttrs (
                  _: value:
                  if isAttrs value && value ? module then
                    {
                      what =
                        if value.meta.shortDescription != null then
                          "component (${value.meta.shortDescription})"
                        else
                          "component";
                    }
                  else
                    {
                      children = recurse value;
                    }
                ) attrs;
            in
            output:
            mkChildren (
              mapAttrs (_: value: {
                children = recurse value;
              }) output
            );
        };
      };
    };
  };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-componentsSchemas";
        component = with local.inputs.self.components; nixology.core.componentsSchemas;
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
    nixology.core.componentsSchemas = {
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
