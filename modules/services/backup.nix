# Daily restic backup of the home directory to the Synology NAS
{ config, ... }:

{
  # NFS share from the NAS, mounted on first access (won't block boot if unreachable)
  boot.supportedFilesystems = [ "nfs" ];
  fileSystems."/mnt/Backup-Nixos" = {
    device = "192.168.178.117:/volume1/Backup-Nixos";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "nofail"
    ];
  };

  sops.secrets.restic-password = { };

  services.restic.backups.home = {
    initialize = true; # create the repository on first run
    repository = "/mnt/Backup-Nixos/restic";
    passwordFile = config.sops.secrets.restic-password.path;
    paths = [ "/home/julius" ];
    exclude = [
      "/home/julius/.cache"
      "/home/julius/.local/share/Trash"
      "**/node_modules"
      "**/.direnv"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true; # catch up on a missed run (e.g. VM was off)
      RandomizedDelaySec = "1h";
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
  };
}
