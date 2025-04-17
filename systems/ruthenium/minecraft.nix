{
  pkgs,
  ...
}:
{
  users.users.minecraft = {
    isNormalUser = true;
    packages = with pkgs; [
      tmux
      neovim
      jdk8
      curl
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeg1XlbH/rtR1uXd5GuWiZuJsmGfUtJHccnODKt6pYi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEfwxBuwDrd/yy/69ZRuj7xdCtanimkCuYVWh2ihM4rM"
    ];
  };
  networking.firewall.allowedTCPPorts = [ 25565 ];
}
