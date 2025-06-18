{
  systemName,
  config,
  lib,
  ...
}:
let
  # already defined by the mailserver module
  cfg = config.personal_mailserver;
in
{
  config = lib.mkIf cfg.enable {
    mailserver = {
      stateVersion = 2;
      fqdn = "${systemName}.uwuaxy.net";
      domains = [ "uwuaxy.net" ];
      loginAccounts.axy = {
        hashedPassword = "$2b$05$FeF3WE4cShOUTP/.cOIl1u/eqvIazjSHieewDM.6Y5oODTd9FnJBC";
        aliases = [ "@uwuaxy.net" ];
        catchAll = [ "uwuaxy.net" ];
      };
      certificateScheme = "acme-nginx";
    };
  };
}
