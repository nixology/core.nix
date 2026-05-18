{
  config,
  inputs,
  lib,
  ...
}:
let
  nixpkgs = config.partitions.channels-nixpkgs-unstable.extraInputs.nixpkgs;

  module = {
    # default pkgs
    perSystem =
      { config, system, ... }:
      {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
      };
  };

  component = {
    inherit module;
    dependencies = with inputs.self.components; [ nixology.core.perSystem ];
    meta = {
      shortDescription = "default pkgs";
    };
  };

  checks =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          eval = config.flake.lib.evalComponent { inherit inputs; } (
            with inputs.self.components; nixology.core.pkgs-unfree
          );
        in
        {
          checks.core-pkgs-unfree = pkgs.runCommandLocal "core-pkgs-unfree-check" { } ''
            : ${builtins.seq eval.config "ok"}
            touch $out
          '';
        };
    };
in
{
  imports = [
    checks
  ];
  flake.components = {
    nixology.core.pkgs-unfree = component;
  };
}
