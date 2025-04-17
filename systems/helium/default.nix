{
  system = "x86_64-linux";
  features = (import ../features.nix).mkFeatures {
    desktop = true;
    nixcache = true;
  };
  modules = [
    {
      system.stateVersion = "24.05";
      hardware = {
        defaultPartitions.enable = true;
        cpuVendor = "amd";
      };
      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
      ];
    }
  ];
}
