# Graphical end-user applications
{ pkgs, ... }:

{
  # Steam's NixOS module also enables 32-bit graphics and controller support.
  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  environment.systemPackages = with pkgs; [
    brave
    discord
    easyeffects
    herdr
    spotify
    teams-for-linux
  ];

  # Run EasyEffects in the background (no window) for the whole graphical session (started by UWSM)
  systemd.user.services.easyeffects = {
    description = "EasyEffects audio processing";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [
      "graphical-session.target"
      "pipewire.service"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.easyeffects}/bin/easyeffects --hide-window";
      ExecStop = "${pkgs.easyeffects}/bin/easyeffects --quit";
      Restart = "on-failure";
    };
  };
}
