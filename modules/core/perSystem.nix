{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  implementation = {
    imports = [
      "${local.inputs.flake-parts}/modules/perSystem.nix"
    ];
  };
in
{
  imports = [
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
