{
  inputs,
  ...
}:
let
  module = {
    pkgs.settings.allowUnfree = true;
  };

  component = {
    inherit module;
    dependencies = with inputs.self.components; [
      nixology.core.pkgs
    ];
    meta = {
      shortDescription = "enables unfree packages in `pkgs`";
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
