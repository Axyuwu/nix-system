{
  description = "Axy system configuration";

  inputs = {
    pkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { pkgs, flake-utils, ... }:
    (flake-utils.lib.eachDefaultSystem (system: {
      formatter = pkgs.legacyPackages.${system}.nixfmt-rfc-style;
    }))
    // {
      nixosConfigurations = builtins.mapAttrs (
        name: value:
        pkgs.lib.nixosSystem {
          specialArgs = {
            systemName = name;
          };
          system = value.system;
          modules = value.modules ++ [
            ./common
          ];
        }
      ) (import ./systems);
    };

}
