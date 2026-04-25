{
  pkgs,
  ...
}:
{
  users.users.gtnh = {
    isNormalUser = true;
    packages = with pkgs; [
      tmux
      neovim
      jdk21_headless
      curl
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeg1XlbH/rtR1uXd5GuWiZuJsmGfUtJHccnODKt6pYi"
    ];
  };
  networking.firewall.allowedTCPPorts = [ 25568 ];
}
