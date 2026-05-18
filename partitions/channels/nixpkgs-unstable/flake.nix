{
  description = "A flake for unstable nixpkgs from channels";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
  };
}
