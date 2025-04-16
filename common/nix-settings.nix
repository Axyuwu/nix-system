{
  lib,
  ...
}:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    keep-outputs = true;
    trusted-public-keys = [
      "uwuaxy.net/nixcache:Cs1U4hIsAWS1RqbNTKDRM3KbT6MFCp8bfSdX6rfk5/A="
    ];
    trusted-substituters = lib.attrsets.mapAttrsToList (
      name: _system: "https://${name}.uwuaxy.net/nixcache"
    ) (lib.attrsets.filterAttrs (_name: system: system.features.nixcache) (import ../systems));
    trusted-users = [ "@wheel" ];
  };
}
