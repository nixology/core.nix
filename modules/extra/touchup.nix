local@{ ... }:
let
  inherit (local.inputs.self.components) nixology;

  implementation = local.inputs.flake-parts.flakeModules.touchup;

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-extra-touchup";
        component = nixology.extra.touchup;
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
    nixology.extra.touchup = {
      inherit implementation;

      dependencies = [
        nixology.core.flake
      ];

      meta = {
        description = "Controls which flake attributes appear in `processedFlake` and how they are transformed.";
        shortDescription = "controls which flake attributes appear and how they are transformed";
      };
    };
  };
}
