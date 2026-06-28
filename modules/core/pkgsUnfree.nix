local@{ ... }:
let
  inherit (local.inputs.self.components) nixology;

  implementation = {
    pkgs.settings.allowUnfree = true;
  };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-pkgsUnfree";
        component = nixology.core.pkgsUnfree;
        extraChecks = ({ eval, ... }: [ eval.config.pkgs.settings.allowUnfree ]);
        inherit (module) config;
      };
    };
in
{
  imports = [ check ];

  flake.components = {
    nixology.core.pkgsUnfree = {
      inherit implementation;

      dependencies = [
        nixology.core.pkgs
      ];

      meta = {
        description = "Enable unfree packages in the nixpkgs `pkgs` instance.";
        shortDescription = "enable unfree packages in pkgs";
      };
    };
  };
}
