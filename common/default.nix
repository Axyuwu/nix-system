{
  systemName,
  lib,
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./cfdyndns.nix
    ./autosubs.nix
    ./hardware.nix
    ./desktop.nix
    ./headless.nix
    ./nixcache.nix
    ./nix-settings.nix
    ./mailserver.nix
    ./magikonfig
  ];

  boot.loader.systemd-boot = lib.mkIf (config.hardware.bootFirmware == "uefi") {
    enable = true;
    configurationLimit = 16;
    editor = false;
    graceful = true;
  };
  boot.loader.efi.canTouchEfiVariables = lib.mkIf (config.hardware.bootFirmware == "uefi") true;
  boot.loader.grub = lib.mkIf (config.hardware.bootFirmware == "bios") {
    enable = true;
  };
  boot.loader.timeout = 2;
  boot.supportedFilesystems = [ "ntfs" ];

  networking.networkmanager.enable = true;

  networking.hostName = systemName;

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "gilliardmarthey.axel@gmail.com";
  };
  services.nginx = {
    recommendedProxySettings = lib.mkDefault true;
    recommendedTlsSettings = lib.mkDefault true;
    recommendedOptimisation = lib.mkDefault true;
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

  users.users.axy = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeg1XlbH/rtR1uXd5GuWiZuJsmGfUtJHccnODKt6pYi"
    ];
    hashedPassword = "$y$j9T$hOeiMzRe59HQfJqmh/iXE/$OPDAqrtFRa4qMe29QOblw355k0j3fnzpcXdbjzq5lM4";
  };
  users.mutableUsers = false;

  services.udisks2.enable = true;

  security.polkit.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80
      443
    ];
  };

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "sysupdate";
      text = ''
        sudo nixos-rebuild switch --flake "github:Axyuwu/nix-system"
      '';
    })
  ];
}
