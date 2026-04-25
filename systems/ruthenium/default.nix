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
      boot.loader.grub.device = "nodev";
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
        ./ft.nix
        ./gitolite.nix
        ./cheesecraft.nix
        ./gtnh.nix
      ];
    }
    {
      services.nginx.enable = true;
      services.nginx.virtualHosts."ruthenium.uwuaxy.net" = {
        forceSSL = true;
        enableACME = true;
        root = "/var/www/";
        extraConfig = ''
          autoindex on;
        '';
      };
    }
  ];
}
