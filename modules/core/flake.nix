{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  inherit (local.lib.components) evalComponent;

  implementation =
    { ... }@module:
    {
      imports = [
        "${local.inputs.flake-parts}/modules/flake.nix"
      ];

      config = {
        perSystem = { pkgs, ... }: {
          checks =
            let
              inherit (evalComponent { inherit (module) inputs; } nixology.core.flake) config;
            in
            {
              nixology-core-flake = pkgs.runCommandLocal "checks" {
                check_flake = builtins.seq config.flake "ok";
              } "touch $out";
            };
        };
      };
    };
in
{
  imports = [
    implementation
  ];

  flake.components = {
    nixology.core.flake = {
      inherit implementation;

      dependencies = [
        nixology.core.perSystem
      ];

      meta = {
        description = "Expose the upstream flake-parts flake module as a nixology component.";
        shortDescription = "flake-parts flake component";
      };
    };
  };
}
