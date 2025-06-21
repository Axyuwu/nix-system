pkgs:
let
  lib = pkgs.lib;
  magikonfig-gen-hardware = pkgs.writeShellApplication {
    name = "magikonfig-gen-hardware";
    runtimeInputs = with pkgs; [
      systemd
      coreutils-full
      gnused
      gnugrep
    ];
    text = ''
      virt=$(case $(systemd-detect-virt || true) in
          none)
              echo "none"
          ;;
          qemu|kvm)
              echo "qemu"
          ;;
          systemd-nspawn)
              echo "systemd-nspawn"
          ;;
          *) 
              echo "other-unknown"
          ;;
      esac)

      vendor_id=$(sed -n 's/^vendor_id[[:space:]]*: \(.*\)/\1/p' /proc/cpuinfo | head -n 1)

      cpu_vendor=$(case $vendor_id in
          "AuthenticAMD")
              echo "amd"
          ;;
          "GenuineIntel")
              echo "intel"
          ;;
          *)
              echo "other-unknown"
          ;;
      esac)

      modules=()

      for path in /sys/bus/pci/devices/*; do
          vendor=$(cat "$path/vendor")
          device=$(cat "$path/device")

          if [[ -e "$path/driver/module" ]] \
              && grep -qE '(0x01|0x0C00|0x0c03).*' "$path/class" 
          then
              modules+=("$(basename "$(readlink -f "$path/driver/module")")")
          fi

          # Virtio scsi devices need to be explicitly discovered
          if [[ "$vendor" == "0x1af4" && ("$device" == "0x1004" || "$device" == "0x1048") ]]; then
              modules+=("virtio_scsi")
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

      for path in /sys/class/block/*/device /sys/class/mmc_host/*/device; do
          if [[ -e "$path/driver/module" ]]; then
              modules+=("$(basename "$(readlink -f "$path/driver/module")")")
          fi
      done

      modules_flat=$(IFS=$'\n'; sort -u <<<"''${modules[*]}")

      kvm_enable=$(if grep -qE "^flags[[:space:]]*:.* (vmx|svm).*" /proc/cpuinfo; then
          echo "true"
      else
          echo "false"
      fi);

      system=$(nix eval --impure --raw --expr "builtins.currentSystem")

      boot_firmware=$(if [[ "$virt" == "none" ]]; then
          if [[ -e /sys/firmware/efi ]]; then
              echo "uefi"
          else
              echo "bios"
          fi
      else
          echo "none-container"
      fi)

      modules_out=$(for module in $modules_flat; do printf '\n       "%s"' "$module"; done)

      cat <<EOF
      {
        system = "$system";
        modules = [
          {
            system.stateVersion = "${builtins.substring 0 5 lib.version}";
            hardware = {
              defaultPartitions.enable = true;
              cpuVendor = "$cpu_vendor"
              virtualization = "$virt";
              kvm.enable = $kvm_enable;
              bootFirmware = "$boot_firmware"
            };
            boot.initrd.availableKernelModules = [$modules_out
            ];
          }
        ];
      }
      EOF
    '';
  };
  magikonfig-format = pkgs.writeShellApplication {
    name = "magikonfig-format";
    runtimeInputs = with pkgs; [
      coreutils-full
      parted
      util-linux
      e2fsprogs
      dosfstools
    ];
    text = ''
      if [[ $# != 2 ]]; then
          >&2 echo "please provide two arguments, the device and the swap size"
          exit 1
      fi

      device="$1"
      swap="$2"

      if [[ -e /sys/firmware/efi ]]; then
          parted -s "$device" -- mklabel gpt
          parted -s "$device" -- mkpart root ext4 512MB "-$swap"
          parted -s "$device" -- mkpart swap linux-swap "-$swap" 100%
          parted -s "$device" -- mkpart ESP fat32 1MB 512MB
          parted -s "$device" -- set 3 esp on
      else
          parted -s "$device" -- mklabel msdos
          parted -s "$device" -- mkpart primary 1MB "-$swap"
          parted -s "$device" -- set 1 boot on
          parted -s "$device" -- mkpart primary linux-swap "-$swap" 100%
      fi

      lsblk -nlo NAME "$device" | (
          read -r #ignore the block device itself
          (read -r nixos; mkfs.ext4 -L nixos "/dev/$nixos")
          (read -r swap; mkswap -L swap "/dev/$swap")
          (if read -r boot; then mkfs.fat -F 32 -n boot "/dev/$boot"; fi)
      )

      mount /dev/disk/by-label/nixos /mnt

      if [[ -e /dev/disk/by-label/boot ]]; then
          mkdir -p /mnt/boot
          mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
      fi

      swapon /dev/disk/by-label/swap
    '';
  };
  magikonfig-install = pkgs.writeShellApplication {
    name = "magikonfig-install";
    runtimeInputs = [ ];
    text = ''
      if [[ $# != 1 ]]; then
          >&2 echo "please provide the machine name as an argument"
          exit 1
      fi

      NIX_CONFIG=$'extra-experimental-features = nix-command flakes\ntarball-ttl = 0' \
      nixos-install --flake "github:Axyuwu/nix-system#$1" --no-root-password 
    '';
  };
  magikonfig = pkgs.writeShellApplication {
    name = "magikonfig";
    runtimeInputs = with pkgs; [
      coreutils-full
      git
      magikonfig-gen-hardware
      magikonfig-format
      magikonfig-install
      gnused
      vim
    ];
    text = ''
      if [[ $(id -u) != 0 ]]; then
          echo "Beware this command is dangerous!"
          echo "Error, magikonfig is required to run as root"
          exit 1
      fi
      if [[ $# != 1 ]]; then
          >&2 echo "please provide the device as an argument"
          exit 1
      fi

      read -r -p "Swap size? (e.g. 2GB) " swap
      magikonfig-format "$1" "$swap"

      read -r -p "Machine name? " machine_name

      cd "$(mktemp -d)"

      git clone https://github.com/Axyuwu/nix-system.nix ./

      mkdir "./systems/$machine_name"

      magikonfig-gen-hardware > "./systems/$machine_name/default.nix"

      while true; do
          vim "./systems/$machine_name/default.nix"
          read -r -p "Done? (y)es (e)dit (q)uit" answer
          case "$answer" in
              y|yes)
                  break
              ;;
              e|edit)
                  true
              ;;
              q|quit)
                  echo "exiting"
                  exit 0
              ;;
              *)
                  echo "Please give a valid answer"
              ;;
          esac
      done

      old_systems=$(cat ./systems/default.nix)
      echo "$old_systems" \
      | (
          read -r
          echo '{'
          echo "  $machine_name = import ./$machine_name;"
      ) > ./systems/default.nix

      git add .

      git commit -am "Automatic initial commit for system $machine_name"

      git push

      magikonfig-install "$machine_name"
    '';
  };
in
pkgs.symlinkJoin {
  name = "magikonfig";
  paths = [
    magikonfig-gen-hardware
    magikonfig-install
    magikonfig-format
    magikonfig
  ];
}
