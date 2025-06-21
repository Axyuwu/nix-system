{
  system = "x86_64-linux";
  headless = true;
  nixcache = true;
  modules = [
    {
      system.stateVersion = "24.11";
      hardware = {
        defaultPartitions.enable = true;
        cpuVendor = "amd";
        virtualization = "none";
        kvm.enable = true;
        bootFirmware = "uefi";
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
    {
      imports = [
        ./minecraft.nix
        ./ntm_space.nix
      ];
      mailserver.enable = true;
    }
  ];
}
