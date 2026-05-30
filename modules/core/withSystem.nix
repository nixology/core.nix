{ inputs, ... }:
let
  implementation = {
    imports = [
      "${inputs.flake-parts}/modules/withSystem.nix"
    ];
  };

  check =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          withSystemComponent = with inputs.self.components; nixology.core.withSystem;

          evalWithSystem = config.flake.lib.evalComponent { inherit inputs; } withSystemComponent;
        in
        {
          checks.core-withSystem = pkgs.runCommandLocal "core-withSystem-check" { } ''
            : ${builtins.seq evalWithSystem.config "ok"}
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
    nixology.core.withSystem = {
      inherit implementation;

      meta = {
        description = "Expose the upstream flake-parts withSystem module as a nixology component.";
        shortDescription = "flake-parts withSystem component";
      };
    };
  };
}
