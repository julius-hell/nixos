# Hyprland desktop: compositor, login screen, shell and the tools
# called from the dotfiles in ~/.config/hypr
{ lib, pkgs, ... }:

{
  # Launched via UWSM so graphical-session.target gets activated
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  services.xserver.enable = true;

  # Graphical login screen, defaulting to the Hyprland (UWSM) session
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = false;
    };
    defaultSession = "hyprland-uwsm";
  };

  # Noctalia desktop shell, started automatically in the graphical session.
  # Also handles idle (lock/screen off/suspend), the lock screen (PAM "login") and the polkit agent.
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    recommendedServices.enable = true;
  };

  # recommendedServices would enable it by default; it would race Noctalia's idle timers
  services.hypridle.enable = lib.mkForce false;

  # Hint Electron/Chromium apps to use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    kitty # default terminal in Hyprland's stock config
    alacritty
    kdePackages.dolphin
    jq # used by ~/.config/hypr/focus-or-launch-alacritty.sh
    yazi # SUPER+Y
    brightnessctl # brightness keys
    playerctl # media keys
    hyprshot # ALT+SHIFT+4/5/6 screenshots
    wl-clipboard # wl-copy/wl-paste; Claude Code reads pasted images via wl-paste
    glib # gsettings (dark theme on startup)
    qt6Packages.qt6ct # QT_QPA_PLATFORMTHEME=qt6ct
    adwaita-icon-theme # XCURSOR_THEME=Adwaita
  ];
}
