{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  implementation =
    { ... }@module:
    {
      imports = [
        "${local.inputs.flake-parts}/modules/moduleWithSystem.nix"
      ];

      config = {
        perSystem = { pkgs, ... }: {
          checks =
            let
              inherit (local.config.flake.lib) evalComponent;
              inherit
                (evalComponent { inherit (module) inputs; } {
                  module = {
                    imports = [
                      nixology.core.debug.module
                      nixology.core.moduleWithSystem.module
                    ];
                  };
                })
                _module
                ;
            in
            {
              nixology-core-moduleWithSystem = pkgs.runCommandLocal "checks" {
                check_module_args_moduleWithSystem = builtins.seq _module.args.moduleWithSystem "ok";
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
    nixology.core.moduleWithSystem = {
      inherit implementation;

      dependencies = [
        nixology.core.perSystem
      ];

      meta = {
        description = "Expose the upstream flake-parts moduleWithSystem module as a nixology component.";
        shortDescription = "flake-parts moduleWithSystem component";
      };
    };
  };
}
