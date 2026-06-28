local@{ ... }:
let
  inherit (local.inputs.self.components) nixology;

  inherit (local.lib)
    mkDefault
    ;

  implementation = {
    imports = [
      "${local.inputs.flake-parts}/modules/debug.nix"
    ];

    config = {
      debug = mkDefault true;
      flake.schemas = { inherit (local.config.flake.exportedSchemas) allSystems currentSystem debug; };
    };
  };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-debug";
        component = nixology.core.debug;
        inherit extraChecks;
        inherit (module) config;
      };
    };

  extraChecks = (
    { evalComponent, component, ... }:
    let
      evalEnabled = evalComponent {
        module = {
          imports = [
            component.module
          ];
        };
      };
    in
    [
      evalEnabled.config
      evalEnabled.config.allSystems
      evalEnabled.config.debug
    ]
  );
in
{
  imports = [
    check
    implementation
  ];

  flake.components = {
    nixology.core.debug = {
      inherit implementation;

      dependencies = [
        nixology.core.perSystem
        nixology.core.schemas
      ];

      meta = {
        description = "Expose debug attributes for the flake.";
        shortDescription = "expose debug attributes for the flake";
      };
    };
  };
}
