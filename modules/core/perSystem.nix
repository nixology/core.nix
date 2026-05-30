{ inputs, ... }:
let
  implementation = {
    imports = [
      "${inputs.flake-parts}/modules/perSystem.nix"
    ];
  };

  check =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          perSystemComponent = with inputs.self.components; nixology.core.perSystem;

          evalPerSystem = config.flake.lib.evalComponent { inherit inputs; } perSystemComponent;
        in
        {
          checks.core-perSystem = pkgs.runCommandLocal "core-perSystem-check" { } ''
            : ${builtins.seq evalPerSystem.config "ok"}
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
    nixology.core.perSystem = {
      inherit implementation;

      meta = {
        description = "Expose the upstream flake-parts perSystem module as a nixology component.";
        shortDescription = "flake-parts perSystem component";
      };
    };
  };
}
