local@{ ... }:
let
  inherit (local.config.partitions.schemas.extraInputs) flake-schemas;

  module = {
    imports = [
      "${local.inputs.flake-parts}/modules/checks.nix"
      "${local.inputs.flake-parts}/modules/formatter.nix"
    ];

    config = {
      flake.schemas = {
        inherit (flake-schemas.exportedSchemas) checks formatter;
      };

      perSystem =
        { pkgs, ... }:
        let
          yamlfmtConfig = pkgs.writeText ".yamlfmt.yaml" ''
            formatter:
              type: basic
              retain_line_breaks: true
              trim_trailing_whitespace: true
          '';

          treefmtConfig = pkgs.writeText "treefmt.toml" ''
            [formatter.deadnix]
            command = "deadnix"
            includes = [
              "**/*.nix",
            ]

            [formatter.just]
            command = "just"
            options = ["--fmt", "--unstable", "--justfile"]
            includes = [
              "justfile",
              "Justfile",
              "**/justfile",
              "**/Justfile",
            ]

            [formatter.nixfmt]
            command = "nixfmt"
            includes = [
              "**/*.nix",
            ]

            [formatter.yamlfmt]
            command = "yamlfmt"
            options = ["-conf", "${yamlfmtConfig}"]
            includes = [
              "**/*.yml",
              "**/*.yaml",
            ]

            [formatter.zizmor]
            command = "zizmor"
            includes = [
              ".github/workflows/*.yml",
              ".github/workflows/*.yaml",
              ".github/actions/**/*.yml",
              ".github/actions/**/*.yaml",
            ]
          '';
        in
        {
          formatter = pkgs.writeShellApplication {
            name = "formatter";

            runtimeInputs = [
              pkgs.deadnix
              pkgs.just
              pkgs.nixfmt
              pkgs.treefmt
              pkgs.yamlfmt
              pkgs.zizmor
            ];

            text = ''
              treefmt --tree-root "$PWD" --config-file "${treefmtConfig}"
            '';
          };
        };
    };
  };
in
{
  imports = [ module ];
}
