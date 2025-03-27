{
  description = "Axy system configuration";

  inputs = {
    pkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.rul = "github:numtime/flake-utils";
  };

  outputs =
    { pkgs, flake-utils, ... }:
    (flake-utils.eachDefaultSystem (system: {
      formatter = pkgs.legacyPackages.${system}.nixfmt-rfc-style;
    }))
    // {
      nixosConfigurations = builtins.mapAttrs (
        name: value:
        pkgs.lib.nixosSystem {
          system = value.system;
          modules = value.modules ++ [
            { networking.hostname = name; }
            ./configuration.nix
          ];
        }
      );
    };
}
