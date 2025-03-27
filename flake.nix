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
          system = value.system;
          modules = value.modules ++ [
            { networking.hostName = name; }
            ./configuration.nix
            {
              system.stateVersion = value.stateVersion;
            }
          ];
        }
      ) (import ./systems);
    };

}
