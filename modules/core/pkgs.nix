{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config;

  module =
    { config, lib, ... }:
    {
      options =
        with lib;
        with types;
        {
          pkgs = mkOption {
            description = "The package set to use for this `pkgs` module args.";
            default = { };
            type = submodule ({
              options = {
                nixpkgs = mkOption {
                  type = path;
                  default = cfg.partitions.channels-nixpkgs-unstable.extraInputs.nixpkgs;
                  description = "The nixpkgs expression to use for pkgs.";
                };
                settings = mkOption {
                  type = types.submodule {
                    freeformType = types.lazyAttrsOf types.anything;

                    options = {
                      allowAliases = mkOption {
                        type = types.bool;
                        default = true;
                      };

                      allowBroken = mkOption {
                        type = types.bool;
                        default = false;
                      };

                      allowUnfree = mkOption {
                        type = types.bool;
                        default = false;
                      };

                      allowUnfreePackages = mkOption {
                        type = types.listOf types.str;
                        default = [ ];
                      };

                      allowUnsupportedSystem = mkOption {
                        type = types.bool;
                        default = false;
                      };

                      allowVariants = mkOption {
                        type = types.bool;
                        default = true;
                      };

                      checkMeta = mkOption {
                        type = types.bool;
                        default = false;
                      };

                      cudaCapabilities = mkOption {
                        type = types.listOf types.str;
                        default = [ ];
                      };

                      cudaForwardCompat = mkOption {
                        type = types.bool;
                        default = true;
                      };

                      cudaSupport = mkOption {
                        type = types.bool;
                        default = false;
                      };

                      doCheckByDefault = mkOption {
                        type = types.bool;
                        default = false;
                      };

                      enableParallelBuildingByDefault = mkOption {
                        type = types.bool;
                        default = false;
                      };

                      fetchedSourceNameDefault = mkOption {
                        type = types.str;
                        default = "source";
                      };

                      gitConfig = mkOption {
                        type = types.attrsOf types.anything;
                        default = { };
                      };

                      gitConfigFile = mkOption {
                        type = types.nullOr types.path;
                        default = null;
                      };

                      hashedMirrors = mkOption {
                        type = types.listOf types.str;
                        default = [ ];
                      };

                      microsoftVisualStudioLicenseAccepted = mkOption {
                        type = types.bool;
                        default = false;
                      };

                      npmRegistryOverrides = mkOption {
                        type = types.attrsOf types.anything;
                        default = { };
                      };

                      npmRegistryOverridesString = mkOption {
                        type = types.str;
                        default = "{}";
                      };

                      replaceStdenv = mkOption {
                        type = types.nullOr types.anything;
                        default = null;
                      };

                      rocmSupport = mkOption {
                        type = types.bool;
                        default = false;
                      };

                      showDerivationWarnings = mkOption {
                        type = types.listOf types.str;
                        default = [ ];
                      };

                      strictDepsByDefault = mkOption {
                        type = types.bool;
                        default = false;
                      };

                      structuredAttrsByDefault = mkOption {
                        type = types.bool;
                        default = false;
                      };

                      warnUndeclaredOptions = mkOption {
                        type = types.bool;
                        default = false;
                      };
                    };
                  };

                  default = { };
                  description = "nixpkgs config passed to the nixpkgs import.";
                };
              };
            });
          };
        };
      config = {
        # default pkgs
        perSystem =
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
    };

  component = {
    inherit module;
    dependencies = with inputs.self.components; [ nixology.core.perSystem ];
    meta = {
      shortDescription = "the `pkgs` perSystem module argument";
    };
  };

  checks =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          eval = config.flake.lib.evalComponent { inherit inputs; } (
            with inputs.self.components; nixology.core.pkgs
          );
        in
        {
          checks.core-pkgs = pkgs.runCommandLocal "core-pkgs-check" { } ''
            : ${builtins.seq eval.config "ok"}
            touch $out
          '';
        };
    };
in
{
  imports = [
    checks
    module
  ];
  flake.components = {
    nixology.core.pkgs = component;
  };
}
