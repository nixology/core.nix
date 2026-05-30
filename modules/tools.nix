{ config, inputs, ... }:
let
  inherit (config.partitions.schemas.extraInputs) flake-schemas;

  module = {
    imports = [
      "${inputs.flake-parts}/modules/checks.nix"
      "${inputs.flake-parts}/modules/formatter.nix"
    ];

    config = {
      flake.schemas = {
        inherit (flake-schemas.schemas) checks formatter;
      };

      perSystem =
        { lib, pkgs, ... }:
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
              TMPDIR=$(mktemp -d)

              cat > "$TMPDIR/.yamlfmt.yaml" <<EOF
              formatter:
                type: basic
                retain_line_breaks: true
                trim_trailing_whitespace: true
              EOF

              cat > "$TMPDIR/treefmt.toml" <<EOF
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
              options = ["-conf", "$TMPDIR/.yamlfmt.yaml"]
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
              EOF

              treefmt --tree-root "$PWD" --config-file "$TMPDIR/treefmt.toml"
            '';
          };
        };
    };
  };
in
{
  imports = [ module ];
}
