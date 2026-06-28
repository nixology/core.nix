local@{ ... }:
let
  inherit (local.inputs.self.components) nixology;

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-default";
        component = nixology.core.default;
        extraChecks = ({ eval, ... }: [ eval.config.flakeref ]);
        inherit (module) config;
      };
    };
in
{
  imports = [
    check
  ];

  flake.components = {
    nixology.core.default = {
      implementation = { };

      dependencies = [
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
