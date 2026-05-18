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

  pkgs = map (
    variant:
    let
      pkgs = config.partitions."pkgs-${variant}".extraInputs;

      module = {
        perSystem =
          { system, ... }:
          {
            _module.args.pkgs = builtins.seq pkgs.nixpkgs pkgs.nixpkgs.legacyPackages.${system};
          };
      };
    in
    {
      inherit variant;
      component = {
        inherit module;
        meta = {
          description = "Provides access to standard packages by using ${variant} pkgs as the package source, making it available as the pkgs argument across all perSystem configurations";
          shortDescription = "package set fetched from git repository";
        };
      };
    }
  ) variants;
in
builtins.foldl' lib.recursiveUpdate { } (
  map (pkgs': {
    flake.components = {
      nixology.pkgs.${pkgs'.variant} = pkgs'.component;
    };
  }) pkgs
)
