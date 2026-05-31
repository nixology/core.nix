{ inputs, ... }:
let
  implementation = inputs.flake-parts.flakeModules.partitions;

  check =
    { config, ... }:
    {
      perSystem = config.flake.lib.mkComponentCheck {
        name = "nixology-core-partitions";
        component = with inputs.self.components; nixology.core.partitions;
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
    nixology.core.partitions = {
      inherit implementation;

      dependencies = with inputs.self.components; [
        nixology.core.flake
      ];

      meta = {
        description = "Expose the upstream flake-parts partitions module as a nixology component.";
        shortDescription = "partition management module";
      };
    };
  };
}
