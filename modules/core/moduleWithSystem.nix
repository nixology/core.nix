{ inputs, ... }:
let
  implementation = {
    imports = [
      "${inputs.flake-parts}/modules/moduleWithSystem.nix"
    ];
  };

  check =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          moduleWithSystemComponent = with inputs.self.components; nixology.core.moduleWithSystem;

          evalModuleWithSystem = config.flake.lib.evalComponent { inherit inputs; } moduleWithSystemComponent;
        in
        {
          checks.core-moduleWithSystem = pkgs.runCommandLocal "core-moduleWithSystem-check" { } ''
            : ${builtins.seq evalModuleWithSystem.config "ok"}
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
    nixology.core.moduleWithSystem = {
      inherit implementation;

      meta = {
        description = "Expose the upstream flake-parts moduleWithSystem module as a nixology component.";
        shortDescription = "flake-parts moduleWithSystem component";
      };
    };
  };
}
