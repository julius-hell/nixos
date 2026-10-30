{ ... }:

{
  networking.networkmanager.enable = true;

  # NetworkManager tray applet (systemd user service in the graphical session)
  programs.nm-applet.enable = true;

  # Tailscale daemon (run `sudo tailscale up` once to log in)
  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--operator=julius" ];
  };

  # SSH server: public key login only (authorized keys in core/users.nix), no root login
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # mDNS: resolve *.local hostnames via Avahi (opens UDP 5353 in the firewall)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
