{
  lib,
  modulesPath,
  config,
  ...
}:
{
  options.isHeadless = lib.mkEnableOption "Headless system";
  config = lib.mkIf config.isHeadless (
    import "${modulesPath}/profiles/headless.nix" { inherit lib; }
  );
}
