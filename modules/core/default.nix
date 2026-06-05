{ inputs, ... }:
let
  implementation = { };

  check =
    { config, ... }:
    {
      perSystem = config.flake.lib.mkComponentCheck {
        name = "nixology-core-default";
        component = with inputs.self.components; nixology.core.default;
        extraChecks = ({ eval, ... }: [ eval.config.flakeref ]);
        inherit config;
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
        nixology.core.schemas
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
