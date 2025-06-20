{ pkgs, config, ... }:
let
  magikonfig-gen-hardware = pkgs.writeShellApplication {
    name = "magikonfig-gen-hardware";
    runtimeInputs = with pkgs; [
      systemd
      coreutils-full
      gnused
      gnugrep
    ];
    text = ''
      set -ueo pipefail

      virt=$(case $(systemd-detect-virt || true) in
          "none")
              echo -n "none"
              ;;
          "qemu")
              ;&
          "kvm")
              echo -n "qemu"
              ;;
          "systemd-nspawn")
              echo -n "systemd-nspawn"
              ;;
          *) 
              echo -n "other-unknown"
              ;;
      esac)

      vendor_id=$(sed -n 's/^vendor_id[[:space:]]*: \(.*\)/\1/p' /proc/cpuinfo | head -n 1)

      cpu_vendor=$(case $vendor_id in
          "AuthenticAMD")
              echo -n "amd"
              ;;
          "GenuineIntel")
              echo -n "intel"
              ;;
          *)
              echo -n "other-unknown"
              ;;
      esac)

      modules=()

      for path in /sys/bus/pci/devices/*; do
          if [[ -e "$path/driver/module" ]] \
              && grep -qE '(0x01|0x0C00|0x0c03).*' "$path/class" 
          then
              modules+=("$(basename "$(readlink -f "$path/driver/module")")")
          fi
      done

      for path in /sys/bus/usb/devices/*; do
          if [[ -e "$path/driver/module" ]]; then
              class=$(cat "$path/bInterfaceClass")
              protocol=$(cat "$path/bInterfaceProtocol")
              if [[ $class == "08" || ( $class == "03" && $protocol == "01" ) ]]; then
                  modules+=("$(basename "$(readlink -f "$path/driver/module")")")
              fi
          fi
      done

      modules_flat=$(IFS=$'\n'; sort -u <<<"''${modules[*]}")

      kvm_enable=$(if grep -qE "^flags[[:space:]]*:.* (vmx|svm).*" /proc/cpuinfo; then
          echo "true"
      else
          echo "false"
      fi);

      system=$(nix eval --impure --raw --expr "builtins.currentSystem")

      modules_out=$(for module in $modules_flat; do printf '\n       "%s"' "$module"; done)

      cat <<EOF
      {
        system = "$system";
        modules = [
          {
            system.stateVersion = "${config.system.nixos.release}";
            hardware = {
              defaultPartitions.enable = true;
              cpuVendor = "$cpu_vendor"
              virtualization = "$virt";
              kvm.enable = $kvm_enable;
            };
            boot.initrd.availableKernelModules = [$modules_out
            ];
          }
        ];
      }
      EOF
    '';
  };
in
{
  environment.systemPackages = [ magikonfig-gen-hardware ];
}
