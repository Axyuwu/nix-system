{
  system = "x86_64-linux";
  nixcache = true;
  modules = [
    {
      system.stateVersion = "24.05";
      hardware = {
        defaultPartitions.enable = true;
        cpuVendor = "amd";
        virtualization = "none";
        kvm.enable = true;
        bootFirmware = "uefi";
      };
      boot.loader.grub.device = "nodev";
      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
      ];
    }
    {
      desktop.enable = true;
      services.nginx.enable = true;
      services.nginx.virtualHosts."helium.uwuaxy.net" = {
        root = "/var/www/";
        extraConfig = ''
          autoindex on;
        '';
      };
    }
  ];
}
