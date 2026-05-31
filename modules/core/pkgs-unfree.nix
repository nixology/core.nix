{ inputs, ... }:
let
  implementation = {
    pkgs.settings.allowUnfree = true;
  };

  check =
    { config, ... }:
    {
      perSystem = config.flake.lib.mkComponentCheck {
        name = "nixology-core-pkgs-unfree";
        component = with inputs.self.components; nixology.core.pkgs-unfree;
        extraChecks = ({ eval, ... }: [ eval.config.pkgs.settings.allowUnfree ]);
        inherit config;
      };
    };
in
{
  imports = [ check ];

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
