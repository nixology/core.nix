{ inputs, ... }:
let
  implementation = {
    imports = [
      "${inputs.flake-parts}/modules/perSystem.nix"
    ];
  };

  check =
    { config, ... }:
    {
      perSystem = config.flake.lib.mkComponentCheck {
        name = "nixology-core-perSystem";
        component = with inputs.self.components; nixology.core.perSystem;
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
    nixology.core.perSystem = {
      inherit implementation;

      meta = {
        description = "Expose the upstream flake-parts perSystem module as a nixology component.";
        shortDescription = "flake-parts perSystem component";
      };
    };
  };
}
