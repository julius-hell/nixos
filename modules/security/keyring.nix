{ ... }:

{
  # Secret Service provider (used by Git Credential Manager); unlocked on login via PAM
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true; # GUI to inspect/manage the keyring
}
