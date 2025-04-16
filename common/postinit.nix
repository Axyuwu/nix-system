{
  systemd = {
    timers.postinit = {
      wantedBy = [ "multi-user.target" ];
      timerConfig = {
        OnActiveSec = "10s";
        Unit = "postinit.target";
      };
    };
    targets.postinit = { };
  };
}
