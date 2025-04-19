{
  pkgs,
  ...
}:
{
  users.users.ntm_space = {
    isNormalUser = true;
    packages = with pkgs; [
      tmux
      neovim
      jdk8
      curl
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeg1XlbH/rtR1uXd5GuWiZuJsmGfUtJHccnODKt6pYi"
    ];
  };
  networking.firewall.allowedTCPPorts = [ 25566 ];
}
