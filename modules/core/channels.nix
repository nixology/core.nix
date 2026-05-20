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

  channels = map (
    variant:
    let
      channelInputs = config.partitions."channels-${variant}".extraInputs;

      module = {
        perSystem =
          { system, ... }:
          {
            _module.args.pkgs = builtins.seq channelInputs.nixpkgs channelInputs.nixpkgs.legacyPackages.${system};
          };
      };
    in
    {
      inherit variant;
      component = {
        inherit module;
        meta = {
          description = "Provides access to packages from nixpkgs by using ${variant} channel branch as the package source, making it available as the pkgs argument across all perSystem configurations";
          shortDescription = "package set from ${variant} channel branch";
        };
      };
    }
  ) variants;
in
builtins.foldl' lib.recursiveUpdate { } (
  map (channels': {
    flake.components = {
      nixology.channels.${channels'.variant} = channels'.component;
    };
  }) channels
)
