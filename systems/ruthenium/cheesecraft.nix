{
  pkgs,
  ...
}:
{
  users.users.cheesecraft = {
    isNormalUser = true;
    packages = with pkgs; [
      tmux
      neovim
      jdk21_headless
      curl
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeg1XlbH/rtR1uXd5GuWiZuJsmGfUtJHccnODKt6pYi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIButG4fIiJcf3JvaWZy0Af09mpo9zuA3K8YgySALVwNN"
    ];
  };
  networking.firewall.allowedTCPPorts = [ 25567 ];
}
