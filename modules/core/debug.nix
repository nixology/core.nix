{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  inherit (local.lib.components) evalComponent;

  implementation =
    let
      inherit (local.lib) mkDefault;
    in
    { ... }@module:
    {
      imports = [
        "${local.inputs.flake-parts}/modules/debug.nix"
      ];

      config = {
        debug = mkDefault true;

        flake.schemas = { inherit (local.config.flake.exportedSchemas) allSystems currentSystem debug; };

        perSystem = { pkgs, ... }: {
          checks =
            let
              inherit (evalComponent { inherit (module) inputs; } nixology.core.debug) config;
            in
            {
              nixology-core-debug = pkgs.runCommandLocal "checks" {
                check_allSystems = builtins.seq config.allSystems "ok";
                check_debug = builtins.seq config.debug "ok";
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
