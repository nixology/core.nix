{
  config,
  inputs,
  lib,
  ...
}:
let
  implementation =
    let
      inherit (config.partitions.schemas.extraInputs.flake-schemas.lib) mkChildren;

      version = 1;

      mkSchema = doc: inventory: {
        inherit version doc inventory;
      };

      perSystemDoc = target: ''
        The `${target}` flake output provides the perSystem flake-parts configuration.

        An attribute set consisting of the `perSystem` attributes, plus the extra
        attributes `_module`, `config`, `options`, `extendModules`.

        N.B. these are not part of the `config` parameter, but are merged in for
        debugging convenience.
      '';
    in
    { config, ... }:
    {
      imports = [
        "${inputs.flake-parts}/modules/debug.nix"
      ];

      config = lib.mkIf config.debug {
        flake.schemas = {
          allSystems =
            mkSchema
              ''
                The `allSystems` flake output provides the perSystem flake-parts configuration.

                An attribute set of configured systems, each consisting of the `perSystem`
                attributes, plus the extra attributes `_module`, `config`, `options`,
                `extendModules`.

                N.B. these are not part of the `config` parameter, but are merged in for
                debugging convenience.
              ''
              (
                output:
                mkChildren (
                  builtins.mapAttrs (_name: _value: {
                    what = "perSystem flake-parts configuration";
                  }) output
                )
              );

          debug =
            mkSchema
              ''
                The `debug` flake output provides the top-level flake-parts configuration.

                An attribute set consisting of the `config` attributes, plus the extra
                attributes `_module`, `config`, `options`, `extendModules`.

                N.B. these are not part of the `config` parameter, but are merged in for
                debugging convenience.
              ''
              (_output: {
                what = "top-level flake-parts configuration";
              });

          currentSystem =
            mkSchema
              ''
                ${perSystemDoc "currentSystem"}

                Only available in impure mode.
              ''
              (output: {
                what = "perSystem flake-parts configuration for ${output.allModuleArgs.system}";
              });
        };
      };
    };

  check =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          evalComponent = component: config.flake.lib.evalComponent { inherit inputs; } component;

          debugComponent = with inputs.self.components; nixology.core.debug;

          evalDefault = evalComponent debugComponent;

          evalEnabled = evalComponent {
            module = {
              imports = [
                { debug = true; }
                debugComponent.module
              ];
            };
          };
        in
        {
          checks.core-debug = pkgs.runCommandLocal "core-debug-check" { } ''
            : ${builtins.seq evalDefault.config "ok"}
            : ${builtins.seq evalEnabled.config "ok"}
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
    nixology.core.debug = {
      inherit implementation;

      dependencies = with inputs.self.components; [
        nixology.core.flake
        nixology.core.perSystem
        nixology.core.schemas
      ];

      meta = {
        description = "Expose debug attributes for the flake.";
        shortDescription = "expose debug attributes for the flake";
      };
    };
  };
}
