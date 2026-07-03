{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  inherit (local.lib.components) evalComponent;

  implementation =
    { ... }@module:
    {
      perSystem = { pkgs, ... }: {
        checks =
          let
            inherit (evalComponent { inherit (module) inputs; } nixology.core.default) config;
          in
          {
            nixology-core-default = pkgs.runCommandLocal "checks" {
              check_flakeref = builtins.seq config.flakeref "ok";
            } "touch $out";
          };
      };
    };
in
{
  imports = [
    implementation
  ];

  flake.components = {
    nixology.core.default = {
      inherit implementation;

      dependencies = [
        nixology.core.flake
        nixology.core.flakeref
        nixology.core.moduleWithSystem
        nixology.core.perSystem
        nixology.core.pkgs
        nixology.core.transposition
        nixology.core.withSystem
        nixology.systems.default
      ];

      meta = {
        description = "Default module for nixology.";
        shortDescription = "default module for nixology";
      };
    };
  };
}
