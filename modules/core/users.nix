{ ... }:

{
  # Don't forget to set a password with `passwd`.
  users.users.julius = {
    isNormalUser = true;
    description = "julius";
    extraGroups = [ "networkmanager" "wheel" "docker" "scanner" "lp" ];
    # SSH login (key only, see core/networking.nix)
    openssh.authorizedKeys.keyFiles = [ ../../ssh-jh.pub ];
  };
}
