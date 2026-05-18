{
  description = "A flake for nixos nixpkgs";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };
}
