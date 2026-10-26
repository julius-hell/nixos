# Hyprland desktop: compositor, login screen, shell, lock/idle and the tools
# called from the dotfiles in ~/.config/hypr
{ pkgs, ... }:

{
  # Launched via UWSM so graphical-session.target gets activated
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Graphical login screen, defaulting to the Hyprland (UWSM) session
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    defaultSession = "hyprland-uwsm";
  };

  # Noctalia desktop shell, started automatically in the graphical session
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    recommendedServices.enable = true;
  };

  # Lock screen (module also sets up its PAM service) and idle daemon (~/.config/hypr/hypridle.conf)
  programs.hyprlock.enable = true;
  services.hypridle.enable = true;

  # Polkit agent, started from Hyprland autostart via `systemctl --user start hyprpolkitagent`
  systemd.packages = [ pkgs.hyprpolkitagent ];

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
    glib # gsettings (dark theme on startup)
    qt6Packages.qt6ct # QT_QPA_PLATFORMTHEME=qt6ct
    adwaita-icon-theme # XCURSOR_THEME=Adwaita
  ];
}
