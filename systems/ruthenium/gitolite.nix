{
  services.gitolite = {
    enable = true;
    adminPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeg1XlbH/rtR1uXd5GuWiZuJsmGfUtJHccnODKt6pYi";
    user = "git";
    extraGitoliteRc = ''
      $RC{UMASK} = 0027;
      $RC{ROLES}{MANAGER} = ();
    '';
  };
}
