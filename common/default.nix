{
  systemName,
  config,
  lib,
  ...
}:

{
  imports = [
    ./cfdyndns.nix
    ./autosubs.nix
    ./hardware.nix
    ./desktop.nix
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

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    keep-outputs = true;
    trusted-public-keys = [
      "uwuaxy.net/nixcache:Cs1U4hIsAWS1RqbNTKDRM3KbT6MFCp8bfSdX6rfk5/A="
    ];
    trusted-substituters = [
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

  security.acme = {
    acceptTerms = true;
    defaults.email = "gilliardmarthey.axel@gmail.com";
  };
  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/nixcache-key.priv";
  };

  services.nginx = {
    recommendedProxySettings = lib.mkDefault true;
  };
  services.nginx = {
    enable = true;
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

  users.users.axy = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeg1XlbH/rtR1uXd5GuWiZuJsmGfUtJHccnODKt6pYi"
    ];
  };

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
