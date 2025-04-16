{
  config,
  lib,
  systemName,
  ...
}:
let
  cfg = config.nixcache;
in
{
  options.nixcache = {
    enable = lib.mkEnableOption "Nix cache server";
  };
  config = lib.mkIf cfg.enable {

    services.nix-serve = {
      enable = true;
      secretKeyFile = "/var/nixcache-key.priv";
    };

    services.nginx = {
      enable = true;
      virtualHosts = {
        "${systemName}.uwuaxy.net" = {
          forceSSL = true;
          enableACME = true;
          locations."/nixcache/".proxyPass =
            "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}/";
        };
      };
    };
  };
}
