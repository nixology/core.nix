local@{ ... }:
let
  inherit (local.inputs.self.components) nixology;

  implementation = {
    imports = [
      "${local.inputs.flake-parts}/modules/withSystem.nix"
    ];
  };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-withSystem";
        component = nixology.core.withSystem;
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
      evalWithDebug._module.args.withSystem
    ]
  );
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
