{
  pkgs,
  ...
}:
{
  users.users = builtins.mapAttrs (
    name:
    { ssh_key, ... }:
    {
      isNormalUser = true;
      packages = with pkgs; [
        neovim
        curl
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeg1XlbH/rtR1uXd5GuWiZuJsmGfUtJHccnODKt6pYi"
        ssh_key
      ];
    }
  ) { };
}
