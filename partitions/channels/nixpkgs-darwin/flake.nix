{
  description = "A flake for darwin nixpkgs from channels";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-25.11-darwin/nixexprs.tar.xz";
  };
}
