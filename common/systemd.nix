{
  ...
}:
{
  systemd.targets.deferred-init = {
    wants = [ "multi-user.target" ];
    requires = [ "basic.target" ];
    conflicts = [
      "rescure.service"
      "rescue.target"
    ];
    after = [
      "basic.target"
      "rescue.service"
      "rescue.target"
    ];
  };
  systemd.defaultUnit = "deferred-init.target";
}
