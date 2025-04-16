{
  description = "Axy system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    (flake-utils.lib.eachDefaultSystem (system: {
      formatter = (import nixpkgs { inherit system; }).nixfmt-rfc-style;
    }))
    // {
      nixosConfigurations = builtins.mapAttrs (
        name:
        {
          system,
          modules,
          features,
        }:
        let
          originPkgs = import nixpkgs { inherit system; };
          pkgs = originPkgs.applyPatches {
            name = "nixpkgs-patched";
            src = nixpkgs;
            patches = import ./patches;
          };
        in
        import (pkgs + "/nixos/lib/eval-config.nix") {
          specialArgs = {
            systemName = name;
            systemPlatform = system;
          };
          inherit system;
          modules = modules ++ [
            ./common
            ((import systems/features.nix).toModule features)
          ];
        }
      ) (import ./systems);
    };

}
