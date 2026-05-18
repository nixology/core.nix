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
      channel = config.partitions."channels-${variant}".extraInputs;

      module = {
        perSystem =
          { system, ... }:
          {
            _module.args.pkgs = builtins.seq channel.nixpkgs channel.nixpkgs.legacyPackages.${system};
          };
      };
    in
    {
      inherit variant;
      component = {
        inherit module;
        meta = {
          description = "Provides access to standard packages by using ${variant} channel as the package source, making it available as the pkgs argument across all perSystem configurations";
          shortDescription = "package set fetched from channel tarball";
        };
      };
    }
  ) variants;
in
builtins.foldl' lib.recursiveUpdate { } (
  map (channel: {
    flake.components = {
      nixology.channels.${channel.variant} = channel.component;
    };
  }) channels
)
