{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  implementation =
    { ... }@module:
    {
      imports = [
        "${local.inputs.flake-parts}/modules/withSystem.nix"
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
                      nixology.core.withSystem.module
                    ];
                  };
                })
                _module
                ;
            in
            {
              nixology-core-withSystem = pkgs.runCommandLocal "checks" {
                check_module_args_withSystem = builtins.seq _module.args.withSystem "ok";
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
    nixology.core.withSystem = {
      inherit implementation;

      meta = {
        description = "Expose the upstream flake-parts withSystem module as a nixology component.";
        shortDescription = "flake-parts withSystem component";
      };
    };
  };
}
