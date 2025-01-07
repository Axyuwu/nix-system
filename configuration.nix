{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "axy";
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
    extraGroups = [ "wheel" ];
    packages = [];
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

