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
        "unknown"
      ];
      default = "unknown";
    };
    kvm = {
      enable = options.mkEnableOption "kernel virtualization support";
    };
    platform = options.mkOption {
      description = "What this system is running on, either bare metal or a virtual machine";
      type = types.enum [
        "bareMetal"
        "virtualMachine"
      ];
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.defaultPartitions.enable (
      lib.mkDefault {
        fileSystems."/" = {
          device = "/dev/disk/by-label/nixos";
          fsType = cfg.defaultPartitions.rootFsType;
        };
        fileSystems."/boot" = {
          device = "/dev/disk/by-label/boot";
          fsType = "vfat";
          options = [
            "fmask=0077"
            "dmask=0077"
          ];
        };

        swapDevices = [
          { device = "/dev/disk/by-label/swap"; }
        ];
      }
    ))
    {
      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = systemPlatform;
      hardware.enableRedistributableFirmware = lib.mkDefault (cfg.platform == "bareMetal");
    }
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
            assertion = cfg.platform == "bareMetal";
            message = "can only use kvm on bare metal";
          }
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
