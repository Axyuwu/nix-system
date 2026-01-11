{
  lib,
  config,
  systemPlatform,
  ...
}:
let
  cfg = config.hardware;
in
{
  options.hardware = with lib; {
    defaultPartitions = {
      enable = options.mkEnableOption "default partitions";
      rootFsType = options.mkOption {
        description = "The file system type to use for /";
        type = types.str;
        default = "ext4";
      };
    };
    cpuVendor = options.mkOption {
      description = "Vendor of the cpu of this system";
      type = types.enum [
        "amd"
        "intel"
        "other-unknown"
      ];
    };
    kvm = {
      enable = options.mkEnableOption "kernel virtualization support";
    };
    virtualization = options.mkOption {
      description = "What virtualization platform this is running on, if any";
      type = types.enum [
        "none"
        "qemu"
        "systemd-nspawn"
        "other-unknown"
      ];
    };
    bootFirmware = options.mkOption {
      description = "What boot firmware this system uses";
      type = types.enum [
        "bios"
        "uefi"
        "none-container"
      ];
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.defaultPartitions.enable {
      fileSystems."/" = lib.mkDefault {
        device = "/dev/disk/by-label/nixos";
        fsType = cfg.defaultPartitions.rootFsType;
      };
      fileSystems."/boot" = lib.mkIf (cfg.bootFirmware == "uefi") (
        lib.mkDefault {
          device = "/dev/disk/by-label/boot";
          fsType = "vfat";
          options = [
            "fmask=0077"
            "dmask=0077"
          ];
        }
      );
      swapDevices = lib.mkDefault [
        { device = "/dev/disk/by-label/swap"; }
      ];
    })
    {
      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = systemPlatform;
    }
    (lib.mkMerge (
      lib.attrsets.mapAttrsToList (name: value: lib.mkIf (cfg.virtualization == name) value) {
        "none" = {
          hardware.enableRedistributableFirmware = lib.mkDefault true;
        };
        "qemu" = {
          boot.initrd.availableKernelModules = [
            "virtio_net"
            "virtio_pci"
            "virtio_mmio"
            "virtio_blk"
            "virtio_scsi"
            "9p"
            "9pnet_virtio"
          ];
          boot.initrd.kernelModules = [
            "virtio_balloon"
            "virtio_console"
            "virtio_rng"
            "virtio_gpu"
          ];
        };
        "systemd-nspawn" = {
          boot.isContainer = true;
        };
      }
    ))
    (lib.mkIf (cfg.cpuVendor == "amd") {
      hardware.cpu.amd.updateMicrocode = lib.mkDefault cfg.enableRedistributableFirmware;
    })
    (lib.mkIf (cfg.cpuVendor == "intel") {
      hardware.cpu.intel.updateMicrocode = lib.mkDefault cfg.enableRedistributableFirmware;
    })
    (lib.mkIf cfg.kvm.enable (
      let
        vendor = cfg.cpuVendor;
      in
      {
        assertions = [
          {
            assertion = vendor == "amd" || vendor == "intel";
            message = "cpu vendors other than amd and intel don't support kvm";
          }
        ];
        boot.kernelModules = [ "kvm-${vendor}" ];
      }
    ))
  ];
}
