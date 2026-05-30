{ inputs, ... }:
let
  implementation = {
    pkgs.settings.allowUnfree = true;
  };

  check =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          pkgsUnfreeComponent = with inputs.self.components; nixology.core.pkgs-unfree;

          evalPkgsUnfree = config.flake.lib.evalComponent { inherit inputs; } pkgsUnfreeComponent;
        in
        {
          checks.core-pkgs-unfree = pkgs.runCommandLocal "core-pkgs-unfree-check" { } ''
            : ${builtins.seq evalPkgsUnfree.config "ok"}
            : ${builtins.seq evalPkgsUnfree.config.pkgs.settings.allowUnfree "ok"}
            touch $out
          '';
        };
    };
in
{
  imports = [
    check
  ];

  flake.components = {
    nixology.core.pkgs-unfree = {
      inherit implementation;

      dependencies = with inputs.self.components; [
        nixology.core.pkgs
      ];

      meta = {
        description = "Enable unfree packages in the nixpkgs `pkgs` instance.";
        shortDescription = "enable unfree packages in pkgs";
      };
    };
  };
}
