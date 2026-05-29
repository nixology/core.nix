{
  description = "A flake that provides channel variants";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    nixos.url = "github:nixology/channels.nix?dir=nixos";
    nixos-small.url = "github:nixology/channels.nix?dir=nixos-small";
    nixos-unstable.url = "github:nixology/channels.nix?dir=nixos-unstable";
    nixos-unstable-small.url = "github:nixology/channels.nix?dir=nixos-unstable-small";
    nixpkgs-darwin.url = "github:nixology/channels.nix?dir=nixpkgs-darwin";
    nixpkgs-unstable.url = "github:nixology/channels.nix?dir=nixpkgs-unstable";
  };
}
