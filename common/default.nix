{
  systemName,
  config,
  pkgs,
  ...
}:

{
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 128;
    editor = false;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 2;
  boot.supportedFilesystems = [ "ntfs" ];

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="Virtual Cam" exclusive_caps=1
  '';

  networking.networkmanager.enable = true;

  networking.hostName = systemName;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    keep-outputs = true;
    trusted-public-keys = [
      "uwuaxy.net/nixcache:Cs1U4hIsAWS1RqbNTKDRM3KbT6MFCp8bfSdX6rfk5/A="
    ];
    substituters = [
      "https://helium.uwuaxy.net/nixcache/"
      "https://neon.uwuaxy.net/nixcache/"
    ];
    trusted-users = [ "@wheel" ];
  };

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/nixcache-key.priv";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "gilliardmarthey.axel@gmail.com";
  };
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "${systemName}.uwuaxy.net" = {
        forceSSL = true;
        enableACME = true;
        locations."/nixcache/".proxyPass =
          "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}/";
      };
    };
  };

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
  };

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = null;
    };
  };

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

  users.users.axy = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "adbusers"
    ];
    packages = [ ];
  };

  services.udev.packages = with pkgs; [
    android-udev-rules
    steam-devices-udev-rules
  ];

  services.udisks2.enable = true;

  security.pam.services.swaylock = { };

  security.polkit.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  networking.firewall.enable = false;
}
