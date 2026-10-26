{ ... }:

{
  networking.networkmanager.enable = true;

  # NetworkManager tray applet (systemd user service in the graphical session)
  programs.nm-applet.enable = true;

  # Tailscale daemon (run `sudo tailscale up` once to log in)
  services.tailscale.enable = true;

  services.openssh.enable = true;
}
