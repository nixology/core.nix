local@{ ... }:
let
  inherit (local.lib)
    mkOption
    types
    ;

  inherit (types)
    nullOr
    str
    ;

  implementation = {
    options.flakeref = mkOption {
      type = nullOr str;
      default = null;
      description = "The flake reference for this flake.";
    };
  };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-flakeref";
        component = with local.inputs.self.components; nixology.core.flakeref;
        extraChecks = ({ eval, ... }: [ eval.config.flakeref ]);
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
    nixology.core.flakeref = {
      inherit implementation;

      meta = {
        description = "Provide a unique identifier for the flake.";
        shortDescription = "flake reference option";
      };
    };
  };
}
