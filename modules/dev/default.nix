# Development tooling: editors, git, language runtimes, containers and cloud CLIs
{ pkgs, pkgs-stable, ... }:

{
  programs.git = {
    enable = true;
    # A list keeps the section order: the work includeIf must come after the default user to override it
    config = [
      {
        user = {
          name = "Julius Hell";
          email = "mail@jhell.dev";
        };
      }
      # Work repos commit with the work address
      {
        includeIf."gitdir:/home/julius/projects/slenderiser/".path = "${pkgs.writeText "gitconfig-slenderiser" ''
          [user]
          	email = j.hell@slenderiser.de
        ''}";
      }
      # Git Credential Manager, storing credentials in the Secret Service keyring (see security/keyring.nix)
      {
        credential = {
          helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
          credentialStore = "secretservice";
          # Azure Repos: use Entra ID OAuth tokens (silently refreshed via the MSAL cache) instead of
          # GCM-generated PATs, which get erased on the first 401 and then force a browser re-login
          azreposCredentialType = "oauth";
          # Pass the repo path to GCM so it can tell the Azure DevOps org on `store` as well as `get`
          # (normally set by `git-credential-manager configure`, which never runs on NixOS)
          "https://dev.azure.com".useHttpPath = true;
        };
      }
    ];
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

  # Java on PATH plus JAVA_HOME; the Firebase emulators are JVM-based and need JDK 21+
  programs.java = {
    enable = true;
    package = pkgs.jdk21_headless;
  };

  # Docker daemon (incl. compose plugin); the "docker" group allows use without sudo
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    # Editors and AI agents
    claude-code
    opencode
    zed-editor

    lazygit

    fnm # Node version manager (shell hook in shell/default.nix)
    pnpm

    # Kubernetes and cloud
    kubectl
    kubelogin # Azure AKS auth plugin for kubectl
    freelens-bin
    awscli2
    firebase-tools
    pkgs-stable.azure-cli # broken on unstable (python fabric), taken from stable
    terraform # unfree (BSL), allowed in core/nix.nix

    bruno # API client

    # Databases (the Tabularis SQL client comes from Flatpak, see desktop/flatpak.nix)
    # PostgreSQL client tools only (no server binaries like postgres/initdb/pg_ctl on PATH)
    (runCommand "postgresql-client-${postgresql.version}" { } ''
      mkdir -p $out/bin
      for b in psql pg_dump pg_dumpall pg_restore pg_isready; do
        ln -s ${postgresql}/bin/$b $out/bin/$b
      done
    '')
  ];
}
