{
  pkgs,
  config,
  lib,
  ...
}:

{
  options.isDesktop = lib.mkEnableOption "Desktop related services";
  config = lib.mkIf config.isDesktop {
    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    boot.kernelModules = [ "v4l2loopback" ];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="Virtual Cam" exclusive_caps=1
    '';

    services.pipewire = {
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      config.common.default = "*";
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-wlr
      ];
    };

    users.users.axy.extraGroups = [ "adbusers" ];

    services.udev.packages = with pkgs; [
      android-udev-rules
      steam-devices-udev-rules
    ];

    security.pam.services.swaylock = { };

    security.wrappers = {
      "gsr-kms-server" = {
        owner = "root";
        group = "root";
        capabilities = "cap_sys_admin+ep";
        source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
      };
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
