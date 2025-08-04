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
    (
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.rclone ];
        environment.etc."rclone-mnt.conf".text = ''
          [storage-osmium-1]
          type = sftp
          host = u481158.your-storagebox.de
          user = u481158
          port = 23
          key_file = /etc/ssh/ssh_host_rsa_key
        '';
        systemd.services."rclone-storage-osmium-1" = {
          description = "Rclone mount of storage-osmium-1";
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.rclone}/bin/rclone mount storage-osmium-1: /rclone/storage-osmium-1 --config=/etc/rclone-mnt.conf";
          };
          after = [ "network.target" ];
          wantedBy = ["multi-user.target"];
        };
      }
    )
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
