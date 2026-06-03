{ inputs, ... }:
let
  implementation =
    { config, lib, ... }:
    {
      options.pkgs = lib.mkOption {
        description = "The package set configuration for the `pkgs` module argument.";
        default = { };

        type = lib.types.submodule {
          options = {
            nixpkgs = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = if inputs ? nixpkgs then inputs.nixpkgs else null;
              description = "The nixpkgs source to import.";
              apply = value: (lib.throwIf (value == null) ''
                nixology: `pkgs.nixpkgs` is not set.

                Either set `pkgs.nixpkgs` explicitly, or ensure your flake has
                a `nixpkgs` input (e.g. `inputs.nixpkgs.url = "github:nixos/nixpkgs";`).
              '') value;
            };

            settings = lib.mkOption {
              type = lib.types.submodule {
                freeformType = lib.types.lazyAttrsOf lib.types.anything;

                options = {
                  allowAliases = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                  };

                  allowBroken = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                  };

                  allowUnfree = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                  };

                  allowUnfreePackages = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
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
          _module.args.pkgs = lib.mkOptionDefault (
            import config.pkgs.nixpkgs {
              inherit system;
              config = config.pkgs.settings;
            }
          );
        };
    };

  check =
    { config, ... }:
    {
      perSystem = config.flake.lib.mkComponentCheck {
        name = "nixology-core-pkgs";
        component = with inputs.self.components; nixology.core.pkgs;
        extraChecks = (
          { eval, ... }:
          [
            eval.config.pkgs.settings.allowUnfree
            eval.config.pkgs.nixpkgs
          ]
        );
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
    nixology.core.pkgs = {
      inherit implementation;

      dependencies = with inputs.self.components; [
        nixology.core.perSystem
      ];

      meta = {
        description = "Provide the default nixpkgs package set as the per-system `pkgs` module argument.";
        shortDescription = "provide per-system pkgs";
      };
    };
  };
}
