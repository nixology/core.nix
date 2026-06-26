local@{ ... }:
let
  implementation = {
    imports = [
      "${local.inputs.flake-parts}/modules/transposition.nix"
    ];

    transposition = local.lib.mkOptionDefault { };
  };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-transposition";
        component = with local.inputs.self.components; nixology.core.transposition;
        extraChecks = ({ eval, ... }: [ eval.config.transposition ]);
        inherit (module) config;
      };
    };
in
{
  imports = [
    check
    implementation
  ];

  flake.components = {
    nixology.core.transposition = {
      inherit implementation;

      dependencies = with local.inputs.self.components; [
        nixology.core.flake
        nixology.core.perSystem
      ];

      meta = {
        description = "Expose the upstream flake-parts transposition module as a nixology component.";
        shortDescription = "flake-parts transposition component";
      };
    };
  };
}
