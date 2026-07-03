{
  config ? null,
  lib ? local.inputs.nixpkgs.lib,
  ...
}@local:
let
  inherit (local.inputs.self.components) nixology;

  inherit (lib)
    filter
    getAttrFromPath
    makeExtensible
    mkDefault
    optionals
    setDefaultModuleLocation
    ;

  inherit (lib.components) evalComponent;

  inherit (lib.filesystem)
    pathIsDirectory
    listFilesRecursive
    ;

  inherit (lib.lists)
    head
    last
    ;

  inherit (lib.strings)
    hasSuffix
    splitString
    ;

  flake-parts-lib = import "${local.inputs.flake-parts}/lib.nix" {
    lib = lib.extend (final: prev: library);
    builtinModules = { };
    extraModules = { };
  };

  inherit (flake-parts-lib)
    evalFlakeModule
    ;

  library =
    let
      getFileStem =
        filePath:
        let
          baseName = builtins.baseNameOf filePath;
          stem = builtins.match "(.+)\\.[^.]+$" baseName;
        in
        if stem == null then baseName else builtins.head stem;

      uses =
        {
          components ? [ ],
          ...
        }:
        {
          imports = map (component: component.module) components;
        };

      modulesIn =
        directory:
        if pathIsDirectory directory then
          filter (path: hasSuffix ".nix" path) (listFilesRecursive directory)
        else
          [ ];

      evalComponent = args: component: evalFlakeModule args component.module;

      mkFlake =
        args: module:
        flake-parts-lib.mkFlake args {
          imports = [ module ] ++ optionals (config != null) [ nixology.core.default.module ];
        };

      mkTOMLFlake =
        flakeArgs: tomlFile:
        let
          toml = builtins.fromTOML (builtins.readFile tomlFile);
          source = head toml.sources;

          name = last (splitString "/" source.url);
          componentName = head source.components;

          componentPath = splitString "." "${name}.components.${componentName}";
          module = getAttrFromPath componentPath flakeArgs.inputs;

          args = flakeArgs // {
            inherit (toml.flake) flakeref;
          };
        in
        mkFlake args module;

      metadataForFlakeInput =
        flake: input:
        let
          lock = builtins.fromJSON (builtins.readFile "${flake.outPath}/flake.lock");

          inputName =
            input:
            builtins.head (
              builtins.filter (name: flake.inputs.${name} == input) (builtins.attrNames flake.inputs)
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
        {
          pname = inputName input;
          inherit input;
          src = input;
          ref = ref input;
          rev = rev input;
          url = url input;
          version = version input;
        };
    in
    {
      inherit
        getFileStem
        evalComponent
        metadataForFlakeInput
        mkFlake
        mkTOMLFlake
        modulesIn
        ;
      components = {
        inherit
          evalComponent
          uses
          ;
      };
      flake = {
        inherit
          metadataForFlakeInput
          mkFlake
          mkTOMLFlake
          ;
      };
      parts = {
        inherit (flake-parts-lib)
          defaultModule
          evalFlakeModule
          mkPerSystemOption
          mkPerSystemType
          mkTransposedPerSystemModule
          ;
      };
    };

  implementation =
    { ... }@module:
    {
      flake.lib = mkDefault (makeExtensible (final: library));
      flake.schemas = { inherit (local.config.flake.exportedSchemas) lib; };

      perSystem = { pkgs, ... }: {
        checks =
          let
            inherit (evalComponent { inherit (module) inputs; } nixology.core.lib) config;
          in
          {
            nixology-core-lib = pkgs.runCommandLocal "checks" {
              check_flake_lib_mkFlake = builtins.seq local.lib.flake.mkFlake "ok";
              check_flake_lib_metadataForFlakeInput = builtins.seq local.lib.flake.metadataForFlakeInput "ok";
              check_flake_lib_metadataForFlakeInput_self_flake-parts =
                (local.lib.flake.metadataForFlakeInput local.inputs.self local.inputs.flake-parts).pname;
            } "touch $out";
          };
      };

      touchup = {
        # hide attributes added to lib when using makeExtensible
        attr.lib.attr.__unfix__.enable = false;
      };
    };
in
{
  imports = [
    implementation
  ];

  # provide `flake.lib` attribute for core bootstrap import
  flake = {
    ${if config == null then "lib" else null} = library;
  };

  flake.components = {
    nixology.core.lib = {
      inherit implementation;

      dependencies = [
        nixology.core.perSystem
        nixology.core.schemas
        nixology.extra.touchup
      ];

      meta = {
        description = "Provide helper functions for nixology flakes and components.";
        shortDescription = "library functions for nixology";
      };
    };
  };
}
