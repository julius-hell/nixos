{ ... }:

{
  # Don't forget to set a password with `passwd`.
  users.users.julius = {
    isNormalUser = true;
    description = "julius";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };
}
