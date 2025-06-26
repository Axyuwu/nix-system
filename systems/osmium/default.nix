{
  system = "x86_64-linux";
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
      boot.loader.grub.device = "/dev/sda";
      boot.initrd.availableKernelModules = [
        "ahci"
        "sd_mod"
        "sr_mod"
        "virtio_pci"
        "virtio_scsi"
        "xhci_pci"
      ];
      networking.interfaces.enp1s0.ipv6.addresses = [
        {
          address = "2a01:4f8:c17:1517::1";
          prefixLength = 64;
        }
      ];
    }
  ];
}
