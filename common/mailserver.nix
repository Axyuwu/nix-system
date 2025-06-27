{
  systemName,
  config,
  lib,
  ...
}:
let
  # already defined by the mailserver module
  cfg = config.mailserver;
in
{
  config = lib.mkIf cfg.enable {
    mailserver = {
      stateVersion = 3;
      fqdn = "${systemName}.uwuaxy.net";
      domains = [ "uwuaxy.net" ];
      loginAccounts."axy@uwuaxy.net" = {
        hashedPassword = "$2b$05$cKW9J60CENZUjbpFLXhhkejC/o60KxmItMpO2mslCv5d1Pu8zyRzq";
        aliases = [ "@uwuaxy.net" ];
        catchAll = [ "uwuaxy.net" ];
      };
      certificateScheme = "acme-nginx";
    };
  };
}
