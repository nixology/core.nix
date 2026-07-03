{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  inherit (local.lib.components) evalComponent;

  implementation =
    let
      inherit (local.inputs) flake-parts;
    in
    { ... }@module:
    {
      imports = [
        flake-parts.flakeModules.partitions
      ];

      config = {
        perSystem = { pkgs, ... }: {
          checks =
            let
              inherit (evalComponent { inherit (module) inputs; } nixology.core.partitions) config;
            in
            {
              nixology-core-partitions = pkgs.runCommandLocal "checks" {
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
    nixology.core.partitions = {
      inherit implementation;

      dependencies = [
        nixology.core.flake
      ];

      meta = {
        description = "Expose the upstream flake-parts partitions module as a nixology component.";
        shortDescription = "partition management module";
      };
    };
  };
}
