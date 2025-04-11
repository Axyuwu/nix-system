{ pkgs, ... }:
{
  environment.etc."xdg/nix/nix.conf".text = "include autosubs.conf";
  environment.etc."xdg/nix/autosubs.conf" = {
    text = "";
    mode = "0644";
    group = "autosubs";
    user = "autosubs";
  };
  users.groups.autosubs = { };
  users.users.autosubs = {
    isSystemUser = true;
    group = "autosubs";
  };
  systemd.services.autosubs = {
    description = "Automatic substituters update";
    script = ''
      set -e -u -o pipefail

      CONF="extra-substituters ="

      for HOST in helium neon; do
        if ${pkgs.iputils}/bin/ping -c 1 -W 0.5 "$HOST.uwuaxy.net"; then
          CONF="$CONF https://$HOST.uwuaxy.net/nixcache/"
        fi
      done

      echo -n $CONF > /etc/xdg/nix/autosubs.conf
    '';
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    serviceConfig = {
      User = "autosubs";
      Group = "autosubs";
      Type = "oneshot";
    };
  };
  systemd.timers.autosubs = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "0s";
      OnUnitActiveSec = "5m";
      Unit = "autosubs.service";
    };
  };
}
