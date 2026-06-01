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
      perSystem = config.flake.lib.mkComponentCheck {
        name = "nixology-core-withSystem";
        component = with inputs.self.components; nixology.core.withSystem;
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
            evalWithDebug._module.args.withSystem
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
    nixology.core.withSystem = {
      inherit implementation;

      meta = {
        description = "Expose the upstream flake-parts withSystem module as a nixology component.";
        shortDescription = "flake-parts withSystem component";
      };
    };
  };
}
