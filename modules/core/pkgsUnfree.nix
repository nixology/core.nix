local@{ ... }:
let
  implementation = {
    pkgs.settings.allowUnfree = true;
  };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-pkgsUnfree";
        component = with local.inputs.self.components; nixology.core.pkgsUnfree;
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

      dependencies = with local.inputs.self.components; [
        nixology.core.pkgs
      ];

      meta = {
        description = "Enable unfree packages in the nixpkgs `pkgs` instance.";
        shortDescription = "enable unfree packages in pkgs";
      };
    };
  };
}
