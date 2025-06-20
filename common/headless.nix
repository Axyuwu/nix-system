{
  lib,
  config,
  ...
}:
let
  cfg = config.headless;
in
{
  options.headless.enable = lib.mkEnableOption "headless related services";
  config = lib.mkIf cfg.enable { };
}
