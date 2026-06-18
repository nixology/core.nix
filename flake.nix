{
  description = "A collection of flake components for various purposes.";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  # default channel
  inputs.nixpkgs-unstable.url = "github:nixology/channels.nix?dir=nixpkgs-unstable";

  # follow the default channel for nixpkgs
  inputs.nixpkgs.follows = "nixpkgs-unstable/channel";

  outputs =
    inputs:
    with import ./modules/core/lib.nix { inherit inputs; };
    with flake.lib;
    mkFlake { inherit inputs; } { imports = modulesIn ./modules; };
}
