{ inputs, ... }:
let
  implementation = {
    imports = [
      "${inputs.flake-parts}/modules/flake.nix"
    ];
  };

  check =
    { config, ... }:
    {
      perSystem = config.flake.lib.mkComponentCheck {
        name = "nixology-core-flake";
        component = with inputs.self.components; nixology.core.flake;
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
    nixology.core.flake = {
      inherit implementation;

      meta = {
        description = "Expose the upstream flake-parts flake module as a nixology component.";
        shortDescription = "flake-parts flake component";
      };
    };
  };
}
