local@{ ... }:
let
  implementation = {
    imports = [
      "${local.inputs.flake-parts}/modules/perSystem.nix"
    ];
  };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-perSystem";
        component = with local.inputs.self.components; nixology.core.perSystem;
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
    nixology.core.perSystem = {
      inherit implementation;

      meta = {
        description = "Expose the upstream flake-parts perSystem module as a nixology component.";
        shortDescription = "flake-parts perSystem component";
      };
    };
  };
}
