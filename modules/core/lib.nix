local@{
  config ? null,
  lib ? local.inputs.flake-parts.inputs.nixpkgs-lib.lib,
  ...
}:
let
  inherit (local.inputs.self.components) nixology;

  inherit (lib)
    concatLines
    evalModules
    filter
    getAttrFromPath
    makeExtensible
    mkDefault
    optionals
    setDefaultModuleLocation
    ;

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
        evalModules {
          class = "flake";

          specialArgs = {
            inherit self flake-parts-lib;
            inherit (args) inputs;
          }
          // specialArgs;

          modules = [
            (setDefaultModuleLocation moduleLocation module)
          ]
          ++ optionals (extraConfig != null) [
            local.inputs.self.components.nixology.core.default.module
          ];
        };

      evalComponent = args: component: evalFlakeModule null args component.module;

      mkFlake = flakeArgs: flakeModule: (evalFlakeModule config flakeArgs flakeModule).config.flake;

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

      modulesIn =
        directory:
        if pathIsDirectory directory then
          filter (path: hasSuffix ".nix" path) (listFilesRecursive directory)
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
        { pkgs, ... }:
        let
          evalFn = c: evalComponent { inherit (local) inputs; } c;
          eval = evalFn component;
          extra = extraChecks {
            evalComponent = evalFn;
            inherit eval component;
          };
          seqLine = v: ": ${builtins.seq v "ok"}";
        in
        {
          checks.${name} = pkgs.runCommandLocal "${name}-check" { } (
            concatLines ([ (seqLine eval.config) ] ++ map seqLine extra ++ [ "touch $out" ])
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

  implementation = {
    flake.lib = mkDefault (makeExtensible (final: library));
    flake.schemas = { inherit (local.config.flake.exportedSchemas) lib; };
  };

  check =
    { config, ... }:
    {
      perSystem = config.flake.lib.mkComponentCheck {
        name = "nixology-core-lib";
        component = nixology.core.lib;
        extraChecks = (
          { eval, ... }:
          [
            eval.config.flake.lib.mkFlake
            eval.config.flake.lib.metadataForFlakeInput
            (eval.config.flake.lib.metadataForFlakeInput local.inputs.self local.inputs.flake-parts)
          ]
        );
        inherit config;
      };
    };
in
{
  imports = [
    check
    { flake.schemas = { inherit (local.config.flake.exportedSchemas) lib; }; }
  ];

  # implementation
  flake.lib = makeExtensible (final: library);

  flake.components = {
    nixology.core.lib = {
      inherit implementation;

      dependencies = [
        nixology.core.schemas
      ];

      meta = {
        description = "Provide helper functions for nixology flakes and components.";
        shortDescription = "library functions for nixology";
      };
    };
  };
}
