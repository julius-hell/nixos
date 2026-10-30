# Storage share from the Synology NAS (same host as the backup share)
{ ... }:

{
  # NFS share, mounted on first access (won't block boot if unreachable)
  boot.supportedFilesystems = [ "nfs" ];
  fileSystems."/mnt/Storage" = {
    device = "192.168.178.117:/volume1/Storage";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "nofail"
    ];
  };
}
