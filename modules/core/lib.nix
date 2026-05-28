{
  config ? null,
  inputs,
  lib ? inputs.flake-parts.inputs.nixpkgs-lib.lib,
  ...
}:
let
  flake-schemas = config.partitions.schemas.extraInputs.flake-schemas;
  flake-parts-lib = inputs.flake-parts.lib;

  library =
    let
      coreInputs = inputs;

      evalComponent = args: component: evalFlakeModule null args component.module;

      evalFlakeModule =
        config:
        args@{
          inputs,
          specialArgs ? { },
          self ? inputs.self,
          moduleLocation ? "${self.outPath}/flake.nix",
        }:
        let
          inputsPos = builtins.unsafeGetAttrPos "inputs" args;
          errorLocation =
            # Best case: user makes it explicit
            args.moduleLocation or (
              # Slightly worse: Nix does not technically commit to unsafeGetAttrPos semantics
              if inputsPos != null then
                inputsPos.file
              # Slightly worse: self may not be valid when an error occurs
              else if args ? inputs.self.outPath then
                args.inputs.self.outPath + "/flake.nix"
              # Fallback
              else
                "<mkFlake argument>"
            );
        in
        (
          module:
          lib.evalModules {
            specialArgs = {
              inherit self flake-parts-lib;
              inputs = args.inputs;
            }
            // specialArgs;
            modules = [
              (lib.setDefaultModuleLocation errorLocation module)
            ]
            ++ lib.optionals (config != null) (
              with coreInputs.self.components;
              map (component: component.module) [
                nixology.core.default
              ]
            );
            class = "flake";
          }
        );

      mkFlake =
        flakeArgs: flakeModule:
        let
          eval = evalFlakeModule config flakeArgs flakeModule;
        in
        eval.config.flake;

      mkTOMLFlake =
        flakeArgs: tomlFile:
        let
          toml = builtins.fromTOML (builtins.readFile tomlFile);
          args = flakeArgs // {
            inherit (toml.flake) flakeref;
          };
          source = lib.lists.head toml.sources;
          name = lib.lists.last (lib.strings.split "/" source.url);
          component = lib.lists.head source.components;
          input = "${name}.components.${component}";
          module = lib.getAttrFromPath (lib.strings.splitString "." input) flakeArgs.inputs;
        in
        mkFlake args module;

      modulesIn =
        directory:
        with lib;
        let
          moduleFiles =
            if filesystem.pathIsDirectory directory then
              (filter (n: strings.hasSuffix ".nix" n) (filesystem.listFilesRecursive directory))
            else
              [ ];
        in
        moduleFiles;

      forFlake =
        self:
        let
          lock = builtins.fromJSON (builtins.readFile "${self.outPath}/flake.lock");

          getNode = input: builtins.getAttr (pname input) lock.nodes;

          getLockedNode = input: (getNode input).locked;

          getOriginalNode = input: (getNode input).original;

          pname =
            input:
            builtins.head (
              builtins.filter (name: self.inputs.${name} == input) (builtins.attrNames self.inputs)
            );

          ref = input: (getOriginalNode input).ref;

          rev = input: (getLockedNode input).rev;

          src = input: input;

          url = input: (getLockedNode input).url;

          version =
            input:
            let
              ref' = ref input;
            in
            if builtins.substring 0 1 ref' == "v" then
              builtins.substring 1 ((builtins.stringLength ref') - 1) ref'
            else
              ref';

          metadataForInput = input: {
            pname = pname input;
            ref = ref input;
            rev = rev input;
            src = src input;
            url = url input;
            version = version input;
          };
        in
        {
          inherit
            metadataForInput
            ;
        };

    in
    {
      inherit
        evalComponent
        evalFlakeModule
        forFlake
        mkFlake
        mkTOMLFlake
        modulesIn
        ;
    };

  schema = {
    version = 1;
    doc = ''
      The `lib` flake output provides a collection of functions.
    '';
    inventory =
      let
        inherit (flake-schemas.lib) mkChildren;
      in
      output:
      mkChildren (
        builtins.mapAttrs (name: value: {
          what = if builtins.isFunction value then "library function" else "library value";
        }) output
      );
  };

  module =
    { inputs, ... }:
    {
      flake.lib = lib.mkDefault library;
      flake.schemas.lib = schema;
    };

  component = {
    inherit module;
    dependencies = with inputs.self.components; [
      nixology.core.schemas
    ];
    meta = {
      shortDescription = "library of functions for nixology methodology";
    };
  };

  checks =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          eval = config.flake.lib.evalComponent { inherit inputs; } (
            with inputs.self.components; nixology.core.lib
          );
        in
        {
          checks.core-lib = pkgs.runCommandLocal "core-lib-check" { } ''
            : ${builtins.seq eval.config "ok"}
            touch $out
          '';
        };
    };
in
{
  imports = [ checks ];

  flake.lib = library;
  flake.schemas.lib = schema;

  flake.components = {
    nixology.core.lib = component;
  };
}
