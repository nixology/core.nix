{
  description = "nixpkgs with the unfree bits enabled";

  inputs.nixpkgs.follows = "unstable/nixpkgs";
  inputs.unstable.url = "github:nixology/core.nix?dir=partitions/channels/unstable";

  outputs =
    { nixpkgs, ... }:
    let
      eachSystem = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    nixpkgs
    // {
      legacyPackages = eachSystem (
        system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        }
      );
    };
}
