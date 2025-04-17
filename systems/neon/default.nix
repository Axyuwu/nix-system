{
  system = "x86_64-linux";
  features = (import ../features.nix).mkFeatures {
    desktop = true;
  };
  modules = [
    {
      system.stateVersion = "24.11";
      hardware = {
        defaultPartitions.enable = true;
        cpuVendor = "intel";
      };
      boot.initrd.availableKernelModules = [
        "vmd"
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
    }
  ];
}
