{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  implementation = local.inputs.flake-parts.flakeModules.touchup;
in
{
  imports = [
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
