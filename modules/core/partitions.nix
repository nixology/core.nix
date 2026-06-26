local@{ ... }:
let
  implementation = local.inputs.flake-parts.flakeModules.partitions;

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-partitions";
        component = with local.inputs.self.components; nixology.core.partitions;
        inherit (module) config;
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

      dependencies = with local.inputs.self.components; [
        nixology.core.flake
      ];

      meta = {
        description = "Expose the upstream flake-parts partitions module as a nixology component.";
        shortDescription = "partition management module";
      };
    };
  };
}
