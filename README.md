# nixology/core

Reusable components for composing Nix flakes.

This repository exports:

| Output | Purpose |
| --- | --- |
| `lib` | Helper functions such as `mkFlake`, `evalFlakeModule`, `evalComponent`, `mkTOMLFlake`, and `modulesIn` |
| `components.nixology.core.*` | Core componets like `default`, `flake`, `perSystem`, `withSystem`, `systems`, `pkgs`, and `partitions` |
| `components.nixology.channels.*` | `pkgs` providers backed by Nix channel tarballs |
| `components.nixology.pkgs.*` | `pkgs` providers backed by `github:nixos/nixpkgs` refs |
| `components.nixology.systems.*` | Predefined system sets such as `default`, `default-linux`, `aarch64-linux`, and `x86_64-darwin` |
| `schemas` | Flake schemas for `lib`, `components`, and `checks` |
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
  inputs.core.url = "github:nixology/core";

  outputs =
    inputs: with inputs.core.lib; mkFlake { inherit inputs; } { imports = modulesIn ./modules; };
}
```

## Component families

### `nixology.core`

Core integration with `flake-parts`, including:

- `default`: standard `flake-parts` module stack
- `flake`, `perSystem`, `withSystem`, `moduleWithSystem`, `transposition`: `flake-parts` integration points
- `pkgs`: default package set
- `systems`: default system set
- `partitions`: partition support
- `components`: component schema and dependency resolution
- `schemas`: flake schema support
- `debug`, `flakeref`: debugging and flake identity helpers

### `nixology.channels`

Package-set components sourced from channel tarballs:

- `nixos`
- `nixos-small`
- `nixos-unstable`
- `nixos-unstable-small`
- `nixpkgs-darwin`
- `nixpkgs-unstable`

### `nixology.pkgs`

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
partitions/  Input-only flakes used for systems, schemas, channels, and pkgs variants
justfile     Project maintenance commands
```

## Development

- Show exported outputs: `nix flake show --all-systems`
- Run checks: `nix flake check`
- Refresh nested flake inputs: `just update`
