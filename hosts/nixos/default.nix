# Host "nixos": the Hyprland desktop.
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
    useOSProber = true;
  };

  networking.hostName = "nixos";

  # First NixOS version installed on this machine; keeps stateful data compatible.
  # Do NOT change this on upgrades, see `man configuration.nix` (system.stateVersion).
  system.stateVersion = "26.05"; # Did you read the comment?
}
