{ inputs, ... }:
let
  implementation = { };

  check =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          defaultComponent = with inputs.self.components; nixology.core.default;

          evalDefault = config.flake.lib.evalComponent { inherit inputs; } defaultComponent;
        in
        {
          checks.core-default = pkgs.runCommandLocal "core-default-check" { } ''
            : ${builtins.seq evalDefault.config "ok"}
            touch $out
          '';
        };
    };
in
{
  imports = [
    check
    implementation
  ];

  flake.components = {
    nixology.core.default = {
      inherit implementation;

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
        description = "Default module for nixology.";
        shortDescription = "default module for nixology";
      };
    };
  };
}
