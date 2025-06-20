{ pkgs, ... }:
{
  environment.systemPackages = [ (import ./package.nix pkgs) ];
}
