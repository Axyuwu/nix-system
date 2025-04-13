{
  system = "x86_64-linux";
  modules = [
    {
      system.stateVersion = "24.11";
      hardware = {
        defaultPartitions.enable = true;
        cpuVendor = "intel";
      };
      isDesktop = true;
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
