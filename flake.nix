{
  description = "Axy system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      simple-nixos-mailserver,
      ...
    }:
    (flake-utils.lib.eachDefaultSystem (system: {
      formatter = (import nixpkgs { inherit system; }).nixfmt-rfc-style;
    }))
    // {
      nixosConfigurations = builtins.mapAttrs (
        name:
        {
          system,
          modules,
          headless ? false,
          nixcache ? false,
        }:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        import (nixpkgs + "/nixos/lib/eval-config.nix") {
          specialArgs = {
            systemName = name;
            systemPlatform = system;
          };
          inherit system;
          modules = modules ++ [
            ./common
            simple-nixos-mailserver.nixosModule
            (
              if headless then
                (
                  { config, modulesPath, ... }:
                  {
                    imports = [ "${modulesPath}/profiles/headless.nix" ];
                    config = {
                      assertions = [
                        {
                          assertion = !config.desktop.enable;
                          message = "Enabling headless is entirely incompatible with desktop usage";
                        }
                      ];
                      headless.enable = true;
                    };
                  }
                )
              else
                { }
            )
            {
              config.nixcache.enable = nixcache;
            }
          ];
        }
      ) (import ./systems);
    }
    // (flake-utils.lib.eachDefaultSystem (system: {
      packages.magikonfig =
        let
          pkgs = import nixpkgs { inherit system; };
        in
        import ./common/magikonfig/package.nix pkgs;
    }));
}
