{ inputs, ... }:
let
  variants = [
    "nixos"
    "nixos-small"
    "nixos-unstable"
    "nixos-unstable-small"
    "nixpkgs-darwin"
    "nixpkgs-unstable"
  ];

  channels =
    let
      partition = "channels";
    in
    map (variant: {
      partitions."${partition}-${variant}".extraInputsFlake = ../partitions/${partition}/${variant};
    }) variants;

  schemas =
    let
      partition = "schemas";
    in
    {
      partitions.${partition}.extraInputsFlake = ../partitions/${partition};
    };

  systems =
    let
      partition = "systems";
    in
    {
      partitions.${partition}.extraInputsFlake = ../partitions/${partition};
    };

  module = {
    imports = [
      schemas
      systems
    ]
    ++ channels;
  };
in
module
