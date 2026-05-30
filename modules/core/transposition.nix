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
      perSystem =
        { pkgs, ... }:
        let
          transpositionComponent = with inputs.self.components; nixology.core.transposition;

          evalTransposition = config.flake.lib.evalComponent { inherit inputs; } transpositionComponent;
        in
        {
          checks.core-transposition = pkgs.runCommandLocal "core-transposition-check" { } ''
            : ${builtins.seq evalTransposition.config "ok"}
            touch $out
          '';
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
