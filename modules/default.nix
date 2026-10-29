# Host-independent modules shared by every machine
{
  imports = [
    ./core/locale.nix
    ./core/networking.nix
    ./core/nix.nix
    ./core/secrets.nix
    ./core/users.nix
    ./desktop/apps.nix
    ./desktop/hyprland.nix
    ./dev
    ./security/1password.nix
    ./security/keyring.nix
    ./services/backup.nix
    ./services/printing.nix
    ./services/storage.nix
    ./shell
  ];
}
