{
  systemName,
  lib,
  ...
}:

{
  imports = [
    ./cfdyndns.nix
    ./autosubs.nix
    ./hardware.nix
    ./desktop.nix
    ./postinit.nix
    ./headless.nix
    ./nixcache.nix
    ./nix-settings.nix
  ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 16;
    editor = false;
  };
  boot.loader.efi.canTouchEfiVariables = true;
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
}
