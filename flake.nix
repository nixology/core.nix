{
  description = "A collection of core components for nixology.";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  # default channel
  inputs.default.url = "github:nixology/channels.nix?dir=nixpkgs-unstable";

  # follow the default channel for nixpkgs
  inputs.nixpkgs.follows = "default/channel";

  outputs =
    inputs:
    with import ./modules/core/lib.nix { inherit inputs; };
    with flake.lib;
    mkFlake { inherit inputs; } { imports = modulesIn ./modules; };
}
