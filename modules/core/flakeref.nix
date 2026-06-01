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
      perSystem = config.flake.lib.mkComponentCheck {
        name = "nixology-core-flakeref";
        component = with inputs.self.components; nixology.core.flakeref;
        extraChecks = ({ eval, ... }: [ eval.config.flakeref ]);
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
    nixology.core.flakeref = {
      inherit implementation;

      meta = {
        description = "Provide a unique identifier for the flake.";
        shortDescription = "flake reference option";
      };
    };
  };
}
