{
  description = "A flake for unfree nixpkgs from channels";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    nixpkgs.url = "github:numtide/nixpkgs-unfree/nixpkgs-unstable";
    nixpkgs.inputs.nixpkgs.follows = "nixpkgs-unstable/nixpkgs";
    nixpkgs-unstable.url = "github:nixology/core.nix?dir=partitions/channels/unstable";
  };
}
