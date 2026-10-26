# Graphical end-user applications
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    brave
    discord
    easyeffects
    herdr
    spotify
    teams-for-linux
  ];
}
