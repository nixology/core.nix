{
  description = "A collection of flake components for various purposes.";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  # default pkgs channel
  inputs.channel.url = "github:nixology/channels.nix?dir=nixpkgs-unstable";

  inputs.nixpkgs.follows = "channel/nixpkgs";

  outputs =
    inputs:
    with import ./modules/core/lib.nix { inherit inputs; };
    with flake.lib;
    mkFlake { inherit inputs; } { imports = modulesIn ./modules; };
}
