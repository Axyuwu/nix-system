{
  system = "x86_64-linux";
  features = (import ../features.nix).mkFeatures {
    headless = true;
    nixcache = true;
  };
  modules = [
    {
      system.stateVersion = "24.11";
      hardware = {
        defaultPartitions.enable = true;
        cpuVendor = "amd";
      };
      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "usbhid"
        "sd-mod"
      ];
    }
    (import ./minecraft.nix)
  ];
}
