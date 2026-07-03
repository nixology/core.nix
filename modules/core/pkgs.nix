{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  inherit (local.lib)
    mkOption
    mkOptionDefault
    throwIf
    ;

  inherit (local.lib.components) evalComponent;

  inherit (local.lib.types)
    anything
    bool
    lazyAttrsOf
    listOf
    nullOr
    path
    str
    submodule
    ;

  implementation =
    { ... }@module:
    {
      options = {
        pkgs = mkOption {
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
      };

      config = {
        perSystem =
          { pkgs, system, ... }:
          {
            _module.args.pkgs = mkOptionDefault (
              import module.config.pkgs.nixpkgs {
                inherit system;
                config = module.config.pkgs.settings;
              }
            );

            checks =
              let
                inherit (evalComponent { inherit (module) inputs; } nixology.core.pkgs) config;
              in
              {
                nixology-core-pkgs = pkgs.runCommandLocal "checks" {
                  check_pkgs_settings_allowUnfree = builtins.seq config.pkgs.settings.allowUnfree "ok";
                  check_pkgs_nixpkgs = builtins.seq config.pkgs.nixpkgs "ok";
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
    nixology.core.pkgs = {
      inherit implementation;

      dependencies = [
        nixology.core.perSystem
      ];

      meta = {
        description = "Configurable per-system `pkgs` module argument.";
        shortDescription = "configurable per-system pkgs";
      };
    };
  };
}
