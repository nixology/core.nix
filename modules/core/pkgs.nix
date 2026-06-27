local@{ ... }:
let
  implementation =
    module@{ ... }:
    with local.lib;
    with types;
    {
      options.pkgs = mkOption {
        description = "The package set configuration for the `pkgs` module argument.";
        default = { };

        type = submodule {
          options = {
            nixpkgs = mkOption {
              type = nullOr path;
              default = if local.inputs ? nixpkgs then local.inputs.nixpkgs else null;
              description = "The nixpkgs source to import.";
              apply =
                value:
                (throwIf (value == null) ''
                  nixology: `pkgs.nixpkgs` is not set.

                  Either set `pkgs.nixpkgs` explicitly, or ensure your flake has
                  a `nixpkgs` input (e.g. `inputs.nixpkgs.url = "github:nixos/nixpkgs";`).
                '')
                  value;
            };

            settings = mkOption {
              type = submodule {
                freeformType = lazyAttrsOf anything;

                options = {
                  allowAliases = mkOption {
                    type = bool;
                    default = true;
                  };

                  allowBroken = mkOption {
                    type = bool;
                    default = false;
                  };

                  allowUnfree = mkOption {
                    type = bool;
                    default = false;
                  };

                  allowUnfreePackages = mkOption {
                    type = listOf str;
                    default = [ ];
                  };
                };
              };

              default = { };
              description = "nixpkgs config passed to the nixpkgs import.";
            };
          };
        };
      };

      config.perSystem =
        { system, ... }:
        {
          _module.args.pkgs = mkOptionDefault (
            import module.config.pkgs.nixpkgs {
              inherit system;
              config = module.config.pkgs.settings;
            }
          );
        };
    };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-core-pkgs";
        component = with local.inputs.self.components; nixology.core.pkgs;
        inherit extraChecks;
        inherit (module) config;
      };
    };

  extraChecks = (
    { eval, ... }:
    [
      eval.config.pkgs.settings.allowUnfree
      eval.config.pkgs.nixpkgs
    ]
  );
in
{
  imports = [
    check
    implementation
  ];

  flake.components = {
    nixology.core.pkgs = {
      inherit implementation;

      dependencies = with local.inputs.self.components; [
        nixology.core.perSystem
      ];

      meta = {
        description = "Configurable per-system `pkgs` module argument.";
        shortDescription = "configurable per-system pkgs";
      };
    };
  };
}
