{
  systemName,
  pkgs,
  ...
}:
let
  zone_id = "eab55627e02f669df6da275fce15bcc5";
  base_url = "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records";
  dyndns_script = pkgs.writeShellScriptBin "cfdyndns" ''
    shopt -s inherit_errexit
    set -e -u -o pipefail

    RECORD=$(${pkgs.curl}/bin/curl -s -S -G \
    '${base_url}' \
    -d 'type=AAAA' \
    -d 'name.exact=${systemName}.uwuaxy.net' \
    -H @/var/cfdyndns.header \
    | ${pkgs.jq}/bin/jq '.result.[0]')

    ID=$(echo $RECORD | ${pkgs.jq}/bin/jq -r '.id')

    IP=$(
      ${pkgs.iproute2}/bin/ip -o -6 addr show up primary scope global \
      | head -n 1 \
      | (
        read -r num dev fam addr rem
        echo ''${addr%/*}
      ))

    BODY=$(printf '{
      "comment": "Dynamic dns address for host ${systemName}",
      "content": "%s",
      "name": "${systemName}.uwuaxy.net",
      "proxied": false,
      "ttl": 1,
      "type": "AAAA"
    }' \
    $IP)

    RESULT=$(${pkgs.curl}/bin/curl -s -S -X PATCH \
    "${base_url}/$ID" \
    -H 'Content-Type: application/json' \
    -H @/var/cfdyndns.header \
    -d "$BODY")

    if [[ $(echo -n "$RESULT" | ${pkgs.jq}/bin/jq '.success') != "true" ]]; then
      echo "Failed to update cloudflare dns"
      echo "Response:"
      echo -n "$RESULT" | ${pkgs.jq}/bin/jq
      exit 1
    fi
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
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      User = "cfdyndns";
      Group = "cfdyndns";
      Type = "oneshot";
    };
  };
  systemd.timers.cfdyndns = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnUnitActiveSec = "5m";
      Unit = "cfdyndns.service";
    };
  };
}
