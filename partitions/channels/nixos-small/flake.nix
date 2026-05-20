{
  description = "A flake with nixpkgs from small nixos channel";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11-small";
  };
}
