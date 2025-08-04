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
    }
    {
      fileSystems."/sync/osmium-storage-1" = {
        device = "u481158@u481158.your-storagebox.de:";
        fsType = "sshfs";
        options = [
          "nodev"
          "noatime"
          "allow_other"
          "_netdev"
          "IdentityFile=/etc/ssh/ssh_host_rsa_key"
          "reconnect"
          "ServerAliveInterval=15"
          "Port=23"
        ];
      };
    }
    (
      { lib, ... }:
      {
        systemd.network = {
          enable = true;
          networks."30-wan" = {
            matchConfig.Name = "enp1s0";
            networkConfig.DHCP = "ipv4";
            address = [ "2a01:4f8:c17:1517::/64" ];
            routes = [
              { Gateway = "fe80::1"; }
            ];
          };
        };
        networking.networkmanager.enable = lib.mkForce false;
        networking.useDHCP = false;
      }
    )
  ];
}
