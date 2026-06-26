local@{ ... }:
let
  implementation = {
    imports = [
      "${local.inputs.flake-parts}/modules/moduleWithSystem.nix"
    ];
  };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-moduleWithSystem";
        component = with local.inputs.self.components; nixology.core.moduleWithSystem;
        inherit extraChecks;
        inherit (module) config;
      };
    };

  extraChecks = (
    { evalComponent, component, ... }:
    let
      evalWithDebug = evalComponent {
        module = {
          imports = [
            local.inputs.self.components.nixology.core.debug.module
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
