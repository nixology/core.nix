{ config, lib, ... }:
let
  variants = [
    "default"
    "default-darwin"
    "default-linux"
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ];

  inputs = config.partitions.systems.extraInputs;

  systems = map (
    variant:
    let
      module = {
        systems =
          if variant == "default" then
            lib.mkOptionDefault (import inputs."${variant}")
          else
            # n.b. don't want merge semantics here; exclusively want specific systems variant, so mkForce
            lib.mkForce (import inputs."${variant}");
      };
    in
    {
      inherit variant;
      component = {
        inherit module;
        meta = {
          shortDescription = "flake systems";
        };
      };
    }
  ) variants;
in
{
  imports = map (x: x.component.module) (builtins.filter (x: x.variant == "default") systems);
}
// (builtins.foldl' lib.recursiveUpdate { } (
  map (systems': {
    flake.components = {
      nixology.systems.${systems'.variant} = systems'.component;
    };
  }) systems
))
