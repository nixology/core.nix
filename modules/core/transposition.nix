{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  implementation =
    { ... }@module:
    {
      imports = [
        "${local.inputs.flake-parts}/modules/transposition.nix"
      ];

      config = {
        transposition = local.lib.mkOptionDefault { };

        perSystem = { pkgs, ... }: {
          checks =
            let
              inherit (local.config.flake.lib) evalComponent;
              inherit (evalComponent { inherit (module) inputs; } nixology.core.transposition) config;
            in
            {
              nixology-core-transposition = pkgs.runCommandLocal "checks" {
                check_transposition = builtins.seq config.transposition "ok";
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
    nixology.core.transposition = {
      inherit implementation;

      dependencies = [
        nixology.core.flake
      ];

      meta = {
        description = "Expose the upstream flake-parts transposition module as a nixology component.";
        shortDescription = "flake-parts transposition component";
      };
    };
  };
}
