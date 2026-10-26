# Secrets from secrets/secrets.yaml (edit with `sops secrets/secrets.yaml`).
# Decrypted with a personal age key, not a host key, so any machine works once the
# private key is placed at /var/lib/sops-nix/key.txt (root-only, 0600).
{ pkgs, ... }:

{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.sshKeyPaths = [ ]; # don't derive keys from the host's SSH key
    gnupg.sshKeyPaths = [ ];
  };

  environment.systemPackages = with pkgs; [
    sops # edit secrets/secrets.yaml
    age
  ];
}
