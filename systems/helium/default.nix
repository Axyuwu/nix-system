{
  system = "x86_64-linux";
  modules = [
    {
      system.stateVersion = "24.05";
      hardware = {
        defaultPartitions.enable = true;
        cpuVendor = "amd";
      };
      isDesktop = true;
      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
      ];
    }
  ];
}
