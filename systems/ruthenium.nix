{
  system = "x86_64-linux";
  features = (import ./features.nix).mkFeatures {
    headless = true;
  };
  modules = [
    {
      system.stateVersion = "24.11";
      hardware = {
        defaultPartitions.enable = true;
        enableAllHardware = true;
      };
      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
      ];
    }
  ];
}
