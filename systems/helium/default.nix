{
  system = "x86_64-linux";
  modules = [
    ./hardware-config.nix
    { system.stateVersion = "24.05"; }
  ];
}
