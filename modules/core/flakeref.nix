{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  implementation =
    { ... }@module:
    let
      inherit (local.lib) mkOption;
      inherit (local.lib.components) evalComponent;
      inherit (local.lib.types) nullOr str;
    in
    {
      options = {
        flakeref = mkOption {
          type = nullOr str;
          default = null;
          description = "The flake reference for this flake.";
        };
      };

      config = {
        perSystem = { pkgs, ... }: {
          checks =
            let
              inherit (evalComponent { inherit (module) inputs; } nixology.core.flakeref) config;
            in
            {
              nixology-core-flakeref = pkgs.runCommandLocal "checks" {
                check_flakeref = builtins.seq config.flakeref "ok";
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
    nixology.core.flakeref = {
      inherit implementation;

      dependencies = [
        nixology.core.perSystem
      ];

      meta = {
        description = "Provide a unique identifier for the flake.";
        shortDescription = "flake reference option";
      };
    };
  };
}
