{ ... }:

{
  # Module sets up the polkit/system-auth integration
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "julius" ];
  };

  # Use 1Password as the SSH agent (also enable it in 1Password > Settings > Developer)
  services.gnome.gcr-ssh-agent.enable = false; # gnome-keyring's agent would claim SSH_AUTH_SOCK
  programs.ssh.extraConfig = ''
    Host *
      IdentityAgent ~/.1password/agent.sock
  '';
  environment.variables.SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
}
