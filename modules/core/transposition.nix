{ inputs, lib, ... }:
let
  implementation = {
    imports = [
      "${inputs.flake-parts}/modules/transposition.nix"
    ];

    transposition = lib.mkOptionDefault { };
  };

  check =
    { config, ... }:
    {
      perSystem = config.flake.lib.mkComponentCheck {
        name = "nixology-core-transposition";
        component = with inputs.self.components; nixology.core.transposition;
        extraChecks = ({ eval, ... }: [ eval.config.transposition ]);
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
    nixology.core.transposition = {
      inherit implementation;

      dependencies = with inputs.self.components; [
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
