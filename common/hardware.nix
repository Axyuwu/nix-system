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
      hardware.enableRedistributableFirmware = true;
    }
    (lib.mkIf (cfg.cpuVendor == "amd") {
      hardware.cpu.amd.updateMicrocode = true;
    })
    (lib.mkIf (cfg.cpuVendor == "intel") {
      hardware.cpu.intel.updateMicrocode = true;
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
