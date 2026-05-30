{ config, lib, ... }:
let
  extraInputs = config.partitions.systems.extraInputs;

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
            lib.mkOptionDefault (import extraInputs.${variant})
          else
            lib.mkForce (import extraInputs.${variant});
      };
    in
    {
      inherit implementation;

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
