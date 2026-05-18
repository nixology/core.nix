{
  inputs,
  ...
}:
let
  module = { };

  component = {
    inherit module;
    dependencies = with inputs.self.components; [
      nixology.core.flake
      nixology.core.flakeref
      nixology.core.moduleWithSystem
      nixology.core.perSystem
      nixology.core.pkgs
      nixology.core.transposition
      nixology.core.withSystem
      nixology.systems.default
    ];
    meta = {
      shortDescription = "default module for nixology";
    };
  };

  checks =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          eval = config.flake.lib.evalComponent { inherit inputs; } (
            with inputs.self.components; nixology.core.default
          );
        in
        {
          checks.core-default = pkgs.runCommandLocal "core-default-check" { } ''
            : ${builtins.seq eval.config "ok"}
            touch $out
          '';
        };
    };
in
{
  imports = [ checks ];
  flake.components = {
    nixology.core.default = component;
  };
}
