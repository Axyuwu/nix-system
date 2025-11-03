{
  config,
  ...
}:
{
  services = {
    gitolite = {
      enable = true;
      adminPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeg1XlbH/rtR1uXd5GuWiZuJsmGfUtJHccnODKt6pYi";
      user = "git";
      extraGitoliteRc = ''
        $RC{UMASK} = 0027;
        $RC{ROLES}{MANAGERS} = 1;
        $RC{ROLES}{RELEASE_MANAGERS} = 1;
        $RC{ROLES}{OWNERS} = 1;
        $RC{OWNER_ROLENAME} = "OWNERS";
        push( @{$RC{ENABLE}}, 'D' ); 
        push( @{$RC{ENABLE}}, 'create' ); 
        push( @{$RC{ENABLE}}, 'config' ); 
        push( @{$RC{ENABLE}}, 'option' ); 
        push( @{$RC{ENABLE}}, 'rsync' ); 
        push( @{$RC{ENABLE}}, 'sudo' ); 
        push( @{$RC{ENABLE}}, 'set-default-roles' ); 
      '';
    };
    gitweb = {
      projectroot = "/var/lib/gitolite/repositories";
      extraConfig = ''$projects_list = "/var/lib/gitolite/projects.list"'';
    };
    nginx =
      let
        vhost = "git.uwuaxy.net";
      in
      {
        virtualHosts.${vhost} = {
          forceSSL = true;
          enableACME = true;
        };
        enable = true;
        gitweb = {
          enable = true;
          group = config.services.gitolite.group;
          virtualHost = vhost;
          location = "";
        };
      };
  };
}
