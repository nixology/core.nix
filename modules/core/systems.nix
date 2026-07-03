{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  extraInputs = local.config.partitions.systems.extraInputs;

  variants = [
    "default"
    "default-darwin"
    "default-linux"
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ];

  mkSystemsComponent =
    variant:
    let
      implementation = {
        systems =
          if variant == "default" then
            local.lib.mkOptionDefault (import extraInputs.${variant})
          else
            import extraInputs.${variant};
      };
    in
    {
      inherit implementation;

      dependencies = [
        nixology.core.perSystem
      ];

      meta = {
        description = "Configure the flake systems list using the `${variant}` systems input.";
        shortDescription = "flake systems: ${variant}";
      };
    };

  components = builtins.listToAttrs (
    map (variant: {
      name = variant;
      value = mkSystemsComponent variant;
    }) variants
  );
in
{
  imports = [
    components.default.implementation
  ];

  flake.components = {
    nixology.systems = components;
  };
}
