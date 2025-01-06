{
  description = "Axy system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ... }: {
    nixosConfigurations.axy = nixpkgs.lib.nixosSystem 
    (let system = "x86_64-linux"; in {
      inherit system;
      modules = [ ./configuration.nix ];
    });
  };
}
