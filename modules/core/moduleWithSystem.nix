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
      perSystem = config.flake.lib.mkComponentCheck {
        name = "nixology-core-moduleWithSystem";
        component = with inputs.self.components; nixology.core.moduleWithSystem;
        extraChecks = (
          { evalComponent, component, ... }:
          let
            evalWithDebug = evalComponent {
              module = {
                imports = [
                  inputs.self.components.nixology.core.debug.module
                  { debug = true; }
                  component.module
                ];
              };
            };
          in
          [
            evalWithDebug._module.args.moduleWithSystem
          ]
        );
        inherit config;
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
