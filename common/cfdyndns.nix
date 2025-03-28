{
  systemName,
  pkgs,
  ...
}:
let
  zone_id = "eab55627e02f669df6da275fce15bcc5";
  base_url = "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records";
  dyndns_script = pkgs.writeShellScriptBin "cfdyndns" ''
    set -e -u -o pipefail

    BEARER_AUTH="Authorization: Bearer $(echo -n $(cat /var/cfdyndns.tok))"

    RECORD=$(${pkgs.curl}/bin/curl -G \
    '${base_url}' \
    -d 'type=AAAA' \
    -d 'name.exact=${systemName}.uwuaxy.net' \
    -H "$BEARER_AUTH" \
    | ${pkgs.jq}/bin/jq '.result.[0]')

    ID=$(echo $RECORD | ${pkgs.jq}/bin/jq -r '.id')

    IP=$(${pkgs.curl}/bin/curl https://api64.ipify.org)

    BODY=$(printf '{
      "comment": "Dynamic dns address for host ${systemName}",
      "content": "%s",
      "name": "${systemName}.uwuaxy.net",
      "proxied": false,
      "ttl": 1,
      "type": "AAAA"
    }' \
    $IP)

    ${pkgs.curl}/bin/curl -X PATCH \
    "${base_url}/$ID" \
    -H 'Content-Type: application/json' \
    -H "$BEARER_AUTH" \
    -d "$BODY"
  '';
in
{
  users.groups = {
    cfdyndns = { };
  };
  users.users.cfdyndns = {
    isSystemUser = true;
    group = "cfdyndns";
  };
  systemd.services.cfdyndns = {
    description = "CloudFlare Dynamic DNS";
    script = ''
      ${dyndns_script}/bin/cfdyndns
    '';
    after = [ "network.target" ];
    serviceConfig = {
      User = "cfdyndns";
      Group = "cfdyndns";
      Type = "oneshot";
    };
  };
  systemd.timers."cfdyndns" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "cfdyndns.service";
    };

  };
  environment.systemPackages = [ dyndns_script ];
}
