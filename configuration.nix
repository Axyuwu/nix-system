{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 128;
    editor = false;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 2;
  boot.supportedFilesystems = [ "ntfs" ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 5;
  };

  networking.hostName = "axy";
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
  };

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
   
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "cuda-merged"
  ];

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

  services.avahi.enable = true;

  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
    autoStart = true;
    config = {
      enable = true;
      json = {
        scale = 1.0;
        bitrate = 100000000;
        encoders = [
          {
            encoder = "vaapi";
            codec = "h265";
            width = 1.0;
            height = 1.0;
            offset_x = 0.0;
            offset_y = 0.0;
          }
        ];
      };
    };
  };

  users.users.axy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = [ ];
  };

  environment.systemPackages = with pkgs; [
    vim
    home-manager
  ];

  security.polkit.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  networking.firewall.enable = false;

  system.stateVersion = "24.05"; # DO NOT CHANGE
}
