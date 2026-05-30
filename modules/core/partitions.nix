{ inputs, ... }:
let
  implementation = inputs.flake-parts.flakeModules.partitions;

  check =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          partitionsComponent = with inputs.self.components; nixology.core.partitions;

          evalPartitions = config.flake.lib.evalComponent { inherit inputs; } partitionsComponent;
        in
        {
          checks.core-partitions = pkgs.runCommandLocal "core-partitions-check" { } ''
            : ${builtins.seq evalPartitions.config "ok"}
            touch $out
          '';
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
