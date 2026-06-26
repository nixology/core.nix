local@{ ... }:
let
  implementation = {
    imports = [
      "${local.inputs.flake-parts}/modules/flake.nix"
    ];
  };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-flake";
        component = with local.inputs.self.components; nixology.core.flake;
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
    nixology.core.flake = {
      inherit implementation;

      meta = {
        description = "Expose the upstream flake-parts flake module as a nixology component.";
        shortDescription = "flake-parts flake component";
      };
    };
  };
}
