{
  system = "x86_64-linux";
  modules = [
    {
      system.stateVersion = "24.11";
      hardware = {
        defaultPartitions.enable = true;
        cpuVendor = "intel";
        virtualization = "none";
        kvm.enable = true;
        bootFirmware = "uefi";
      };
      boot.loader.grub.device = "nodev";
      boot.initrd.availableKernelModules = [
        "vmd"
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
    }
    {
      desktop.enable = true;
    }
  ];
}
