{ config, lib, ... }:
let
  variants = [
    "nixos"
    "nixos-small"
    "nixos-unstable"
    "nixos-unstable-small"
    "nixpkgs-darwin"
    "nixpkgs-unstable"
  ];

  branches = map (
    variant:
    let
      branchInputs = config.partitions."branches-${variant}".extraInputs;

      module = {
        perSystem =
          { system, ... }:
          {
            _module.args.pkgs = builtins.seq branchInputs.nixpkgs branchInputs.nixpkgs.legacyPackages.${system};
          };
      };
    in
    {
      inherit variant;
      component = {
        inherit module;
        meta = {
          description = "Provides access to standard packages by using ${variant} branches as the package source, making it available as the pkgs argument across all perSystem configurations";
          shortDescription = "package set fetched from git repository";
        };
      };
    }
  ) variants;
in
builtins.foldl' lib.recursiveUpdate { } (
  map (branches': {
    flake.components = {
      nixology.branches.${branches'.variant} = branches'.component;
    };
  }) branches
)
