local@{
  config ? null,
  lib ? local.inputs.flake-parts.inputs.nixpkgs-lib.lib,
  ...
}:
let
  inherit (config.partitions.schemas.extraInputs) flake-schemas;
  flake-parts-lib = local.inputs.flake-parts.lib;

  library =
    let
      getFileName =
        pos:
        let
          fileName = builtins.baseNameOf pos.file;
          match = builtins.match "(.+)\\.[^.]+$" fileName;
        in
        if match == null then fileName else builtins.head match;

      evalFlakeModule =
        extraConfig:
        args@{
          inputs,
          specialArgs ? { },
          self ? inputs.self,
          moduleLocation ? "${self.outPath}/flake.nix",
        }:
        module:
        lib.evalModules {
          class = "flake";

          specialArgs = {
            inherit self flake-parts-lib;
            inherit (args) inputs;
          }
          // specialArgs;

          modules = [
            (lib.setDefaultModuleLocation moduleLocation module)
          ]
          ++ lib.optionals (extraConfig != null) [
            local.inputs.self.components.nixology.core.default.module
          ];
        };

      evalComponent = args: component: evalFlakeModule null args component.module;

      mkFlake = flakeArgs: flakeModule: (evalFlakeModule config flakeArgs flakeModule).config.flake;

      mkTOMLFlake =
        flakeArgs: tomlFile:
        let
          toml = builtins.fromTOML (builtins.readFile tomlFile);
          source = lib.lists.head toml.sources;

          name = lib.lists.last (lib.strings.splitString "/" source.url);
          componentName = lib.lists.head source.components;

          componentPath = lib.strings.splitString "." "${name}.components.${componentName}";
          module = lib.getAttrFromPath componentPath flakeArgs.inputs;

          args = flakeArgs // {
            inherit (toml.flake) flakeref;
          };
        in
        mkFlake args module;

      modulesIn =
        directory:
        if lib.filesystem.pathIsDirectory directory then
          lib.filter (path: lib.strings.hasSuffix ".nix" path) (lib.filesystem.listFilesRecursive directory)
        else
          [ ];

      metadataForFlakeInput =
        self:
        let
          lock = builtins.fromJSON (builtins.readFile "${self.outPath}/flake.lock");

          inputName =
            input:
            builtins.head (
              builtins.filter (name: self.inputs.${name} == input) (builtins.attrNames self.inputs)
            );

          getNode = input: lock.nodes.${inputName input};
          locked = input: (getNode input).locked;
          original = input: (getNode input).original;

          ref = input: (original input).ref or null;
          rev = input: (locked input).rev or null;
          url = input: (locked input).url or null;

          version =
            input:
            let
              ref' = ref input;
            in
            if ref' == null then
              null
            else if builtins.substring 0 1 ref' == "v" then
              builtins.substring 1 (builtins.stringLength ref' - 1) ref'
            else
              ref';
        in
        input: {
          pname = inputName input;
          inherit input;
          src = input;
          ref = ref input;
          rev = rev input;
          url = url input;
          version = version input;
        };

      mkComponentCheck =
        {
          name,
          component,
          extraChecks ? _: [ ],
          config,
        }:
        { pkgs, lib, ... }:
        let
          evalFn = c: config.flake.lib.evalComponent { inherit (local) inputs; } c;
          eval = evalFn component;
          extra = extraChecks {
            evalComponent = evalFn;
            inherit eval component;
          };
          seqLine = v: ": ${builtins.seq v "ok"}";
        in
        {
          checks.${name} = pkgs.runCommandLocal "${name}-check" { } (
            lib.concatLines ([ (seqLine eval.config) ] ++ map seqLine extra ++ [ "touch $out" ])
          );
        };
    in
    {
      inherit
        getFileName
        evalComponent
        evalFlakeModule
        metadataForFlakeInput
        mkComponentCheck
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
        builtins.mapAttrs (_name: value: {
          what = if builtins.isFunction value then "library function" else "library value";
        }) output
      );
  };

  implementation = {
    flake.lib = lib.mkDefault library;
    flake.schemas.lib = schema;
  };

  check =
    { config, ... }:
    {
      perSystem = config.flake.lib.mkComponentCheck {
        name = "nixology-core-lib";
        component = with local.inputs.self.components; nixology.core.lib;
        extraChecks = (
          { eval, ... }:
          [
            eval.config.flake.lib.mkFlake
            eval.config.flake.schemas.lib
            eval.config.flake.lib.metadataForFlakeInput
            (eval.config.flake.lib.metadataForFlakeInput local.inputs.self local.inputs.flake-parts)
          ]
        );
        inherit config;
      };
    };
in
{
  imports = [ check ];

  # implementation
  flake.lib = library;
  flake.schemas.lib = schema;

  flake.components = {
    nixology.core.lib = {
      inherit implementation;

      dependencies = with local.inputs.self.components; [
        nixology.core.schemas
      ];

      meta = {
        description = "Provide helper functions for nixology flakes and components.";
        shortDescription = "library functions for nixology";
      };
    };
  };
}
