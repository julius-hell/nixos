# Development tooling: editors, git, language runtimes, containers and cloud CLIs
{ pkgs, pkgs-stable, ... }:

{
  # Git Credential Manager, storing credentials in the Secret Service keyring (see security/keyring.nix)
  programs.git = {
    enable = true;
    config.credential = {
      helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
      credentialStore = "secretservice";
    };
  };

  # Fallback Node LTS (pkgs.nodejs, currently 24); projects pin their own via dev shells.
  # Global npm installs go to ~/.local (bins in ~/.local/bin, which is added to PATH).
  programs.npm = {
    enable = true;
    npmrc = ''
      prefix = ''${HOME}/.local
    '';
  };
  environment.localBinInPath = true;

  # Per-project dev shells: auto-load `use flake` from .envrc (nix-direnv included)
  programs.direnv.enable = true;

  # Docker daemon (incl. compose plugin); the "docker" group allows use without sudo
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    # Editors and AI agents
    claude-code
    opencode
    zed-editor

    lazygit

    # Kubernetes and cloud
    kubectl
    kubelogin # Azure AKS auth plugin for kubectl
    freelens-bin
    awscli2
    pkgs-stable.azure-cli # broken on unstable (python fabric), taken from stable

    bruno # API client
  ];
}
