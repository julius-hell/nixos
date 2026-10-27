# Declarative Flatpaks via nix-flatpak: listed apps are installed on activation, unlisted ones removed
{ ... }:

{
  services.flatpak = {
    enable = true;
    uninstallUnmanaged = true;
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };

    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
      # Third-party community repo; the upstream-recommended source for Tabularis
      {
        name = "flatpark";
        location = "https://dl.flatpark.org/flatpark.flatpakrepo";
      }
    ];

    packages = [
      {
        appId = "dev.tabularis.Tabularis"; # SQL client
        origin = "flatpark";
      }
    ];
  };
}
