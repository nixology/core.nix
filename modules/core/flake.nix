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
      perSystem =
        { pkgs, ... }:
        let
          flakeComponent = with inputs.self.components; nixology.core.flake;

          evalFlake = config.flake.lib.evalComponent { inherit inputs; } flakeComponent;
        in
        {
          checks.core-flake = pkgs.runCommandLocal "core-flake-check" { } ''
            : ${builtins.seq evalFlake.config "ok"}
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
    nixology.core.flake = {
      inherit implementation;

      meta = {
        description = "Expose the upstream flake-parts flake module as a nixology component.";
        shortDescription = "flake-parts flake component";
      };
    };
  };
}
