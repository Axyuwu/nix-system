{
  description = "Axy system configuration";

  inputs = {
    pkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "pkgs";
    };
  };

  outputs =
    { pkgs, ... }:
    let
      system = "x86_64-linux";
    in
    {
      formatter.${system} = pkgs.legacyPackages.${system}.nixfmt-rfc-style;
      nixosConfigurations.axy = pkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./configuration.nix ];
      };
    };
}
