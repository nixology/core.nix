{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  implementation =
    { ... }@module:
    {
      pkgs.settings.allowUnfree = true;

      perSystem =
        { pkgs, ... }:
        {
          checks =
            let
              inherit (local.config.flake.lib) evalComponent;
              inherit (evalComponent { inherit (module) inputs; } nixology.core.pkgsUnfree) config;
            in
            {
              nixology-core-pkgsUnfree = pkgs.runCommandLocal "checks" {
                check_pkgs_settings_allowUnfree =
                  if (config.pkgs.settings.allowUnfree == true) then "ok" else abort;
              } "touch $out";
            };
        };
    };
in
{
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
