{ inputs, ... }:
let
  implementation =
    { lib, ... }:
    {
      options.flakeref = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The flake reference for this flake.";
      };
    };

  check =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          flakerefComponent = with inputs.self.components; nixology.core.flakeref;

          evalFlakeref = config.flake.lib.evalComponent { inherit inputs; } flakerefComponent;
        in
        {
          checks.core-flakeref = pkgs.runCommandLocal "core-flakeref-check" { } ''
            : ${builtins.seq evalFlakeref.config "ok"}
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
    nixology.core.flakeref = {
      inherit implementation;

      meta = {
        description = "Provide a unique identifier for the flake.";
        shortDescription = "flake reference option";
      };
    };
  };
}
