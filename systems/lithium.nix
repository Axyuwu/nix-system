{
  system = "x86_64-linux";
  features = (import ./features.nix).mkFeatures {
    headless = true;
  };
  modules = [
    (
      {
        lib,
        ...
      }:
      {
        system.stateVersion = "24.11";
        hardware = {
          defaultPartitions.enable = true;
          enableAllHardware = true;
        };
        swapDevices = lib.mkForce [ ];
      }
    )
  ];
}
