{
  description = "A flake with nixpkgs from nixos channel";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  };
}
