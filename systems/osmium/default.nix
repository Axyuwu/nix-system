{
  system = "x86_64-linux";
  headless = true;
  modules = [
    {
      system.stateVersion = "25.05";
      hardware = {
        defaultPartitions.enable = true;
        cpuVendor = "intel";
        virtualization = "qemu";
        kvm.enable = false;
        bootFirmware = "bios";
      };
      boot.loader.grub.device = "nodev";
      boot.initrd.availableKernelModules = [
       "ahci"
       "sd_mod"
       "sr_mod"
       "virtio_pci"
       "virtio_scsi"
       "xhci_pci"
      ];
    }
  ];
}
