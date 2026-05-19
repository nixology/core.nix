# nixology/core.nix

Reusable components for composing Nix flakes.

This repository exports:

| Output | Purpose |
| --- | --- |
| `lib` | Helper functions such as `mkFlake`, `evalFlakeModule`, `evalComponent`, `mkTOMLFlake`, and `modulesIn` |
| `components.nixology.core.*` | Core components like `default`, `flake`, `perSystem`, `withSystem`, `systems`, `pkgs`, `partitions`, `lib`, and `pkgs-unfree` |
| `components.nixology.channels.*` | `pkgs` providers backed by Nix channel tarballs |
| `components.nixology.branches.*` | `pkgs` providers backed by `github:nixos/nixpkgs` refs |
| `components.nixology.systems.*` | Predefined system sets such as `default`, `default-darwin`, `default-linux`, `aarch64-linux`, and `x86_64-darwin` |
| `schemas` | Flake schemas for `lib`, `components`, `checks`, `formatter`, and `schemas` |
| `formatter` | Formatter wrapping `nixfmt`, `deadnix`, `yamlfmt`, and `zizmor` via `treefmt` |
| `checks` | Evaluation checks for the exported components |

## What it provides

The root flake assembles modules under `modules/` into a component catalog organized as:

```text
components.<domain>.<subdomain>.<name>
```

Each component carries metadata, a module, and optional dependencies. The resolved module for a component imports its dependencies automatically, which makes components usable as building blocks in downstream flakes.

## Usage

```nix
{
  inputs.core.url = "github:nixology/core.nix";

  outputs =
    inputs: with inputs.core.lib; mkFlake { inherit inputs; } { imports = modulesIn ./modules; };
}
```

## Components

### `nixology.core`

Core integration with `flake-parts`, including:

- `default`: base components for Nixology flakes
- `flake`, `perSystem`, `withSystem`, `moduleWithSystem`, `transposition`: `flake-parts` integration points
- `pkgs`: default package set
- `pkgs-unfree`: enables unfree packages in `pkgs`
- `systems`: default system set
- `partitions`: partition support
- `components`: component schema and dependency resolution
- `schemas`: flake schema support
- `lib`: library of helper functions
- `debug`, `flakeref`: debugging and flake identity helpers

### `nixology.channels`

Package-set components sourced from channel tarballs:

- `nixos`
- `nixos-small`
- `nixos-unstable`
- `nixos-unstable-small`
- `nixpkgs-darwin`
- `nixpkgs-unstable`

### `nixology.branches`

Package-set components sourced from `github:nixos/nixpkgs` refs, with the same variants as `nixology.channels`.

### `nixology.systems`

Prebuilt system lists:

- `default`
- `default-darwin`
- `default-linux`
- `aarch64-darwin`
- `aarch64-linux`
- `x86_64-darwin`
- `x86_64-linux`

## Repository layout

```text
modules/     Root modules assembled into the exported flake
modules/core Core component implementations and library helpers
partitions/  Input-only flakes used for branches, channels, schemas, and systems
justfile     Project maintenance commands
```

## Development

- Refresh nested flake inputs: `just update`
