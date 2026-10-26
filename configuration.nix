# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, pkgs-stable, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  # Configure console keymap
  console.keyMap = "us-acentos";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."julius" = {
    isNormalUser = true;
    description = "julius";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];
  environment.systemPackages = with pkgs; [
      claude-code
      git
      opencode
      kitty # default terminal in Hyprland's stock config
      yadm
      lazygit
      fzf # used by fzf-tab
      kubectl
      kubelogin # Azure AKS auth plugin for kubectl
      sops # edit secrets/secrets.yaml
      age
      zed-editor
      discord
      brave
      herdr
      alacritty
      spotify
      teams-for-linux
      easyeffects
      jq # used by ~/.config/hypr/focus-or-launch-alacritty.sh
      awscli2
      pkgs-stable.azure-cli # broken on unstable (python fabric), taken from stable
      freelens-bin
      bruno
      kdePackages.dolphin
      btop
      neovim
      lsd
      bat
      # Called from ~/.config/hypr
      yazi # SUPER+Y
      brightnessctl # brightness keys
      playerctl # media keys
      hyprshot # ALT+SHIFT+4/5/6 screenshots
      glib # gsettings (dark theme on startup)
      qt6Packages.qt6ct # QT_QPA_PLATFORMTHEME=qt6ct
      adwaita-icon-theme # XCURSOR_THEME=Adwaita
  ];

  # Polkit agent, started from Hyprland autostart via `systemctl --user start hyprpolkitagent`
  systemd.packages = [ pkgs.hyprpolkitagent ];

  # NFS share from the Synology NAS, mounted on first access (won't block boot if unreachable)
  boot.supportedFilesystems = [ "nfs" ];
  fileSystems."/mnt/Backup-Nixos" = {
    device = "192.168.178.117:/volume1/Backup-Nixos";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" "nofail" ];
  };

  # Secrets from secrets/secrets.yaml (edit with `sops secrets/secrets.yaml`).
  # Decrypted with a personal age key, not a host key, so any machine works once the
  # private key is placed at /var/lib/sops-nix/key.txt (root-only, 0600).
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.sshKeyPaths = [ ]; # don't derive keys from the host's SSH key
    gnupg.sshKeyPaths = [ ];
    secrets.restic-password = { };
  };

  # Daily restic backup of the home directory to the NAS share above
  services.restic.backups.home = {
    initialize = true; # create the repository on first run
    repository = "/mnt/Backup-Nixos/restic";
    passwordFile = config.sops.secrets.restic-password.path;
    paths = [ "/home/julius" ];
    exclude = [
      "/home/julius/.cache"
      "/home/julius/.local/share/Trash"
      "**/node_modules"
      "**/.direnv"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true; # catch up on a missed run (e.g. VM was off)
      RandomizedDelaySec = "1h";
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
  };

  # VM clipboard sharing with the host via the SPICE agent (needs a Spice display in virt-manager)
  services.spice-vdagentd.enable = true;
  # Session half of the agent; its XDG autostart entry has X-systemd-skip, so UWSM never starts it
  systemd.user.services.spice-vdagent = {
    description = "SPICE guest session agent";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.spice-vdagent}/bin/spice-vdagent -x";
      Restart = "on-failure";
    };
  };

  # Lock screen (module also sets up its PAM service) and idle daemon (~/.config/hypr/hypridle.conf)
  programs.hyprlock.enable = true;
  services.hypridle.enable = true;

  # zsh as login shell; the modules below add their init lines to interactive zsh
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    histSize = 10000; # also sets SAVEHIST; HISTFILE defaults to ~/.zsh_history
    ohMyZsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" ];
    };
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    # fzf-tab isn't packaged as an oh-my-zsh plugin, so source it directly
    interactiveShellInit = ''
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
    '';
    shellAliases = {
      nano = "nvim";
      ls = "lsd";
      cat = "bat";
      lg = "lazygit";
      kustomize = "kubectl kustomize";
    };
  };
  programs.zoxide = {
    enable = true;
    flags = [ "--cmd" "cd" ];
  };
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    # The module points ATUIN_CONFIG_DIR at /etc/atuin, which only exists when
    # settings are non-empty; otherwise atuin tries (and fails) to create it.
    settings.update_check = false; # updates come from Nix
  };
  # Powerline glyphs for the agnoster theme (picked up as a fontconfig fallback)
  fonts.packages = [ pkgs.nerd-fonts.symbols-only ];

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

  # Run unpatched prebuilt binaries (npm deps like esbuild/playwright, nvm-style downloads)
  programs.nix-ld.enable = true;

  # NetworkManager tray applet (systemd user service in the graphical session)
  programs.nm-applet.enable = true;

  # Tailscale daemon (run `sudo tailscale up` once to log in)
  services.tailscale.enable = true;

  # Docker daemon (incl. compose plugin); "docker" group above allows use without sudo
  virtualisation.docker.enable = true;

  # Git Credential Manager, storing credentials in the Secret Service keyring
  programs.git = {
    enable = true;
    config.credential = {
      helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
      credentialStore = "secretservice";
    };
  };

  # Secret Service provider for GCM; unlocked on login via PAM
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true; # GUI to inspect/manage the keyring

  # 1Password (module sets up the polkit/system-auth integration)
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

  # Hyprland (launched via UWSM so graphical-session.target gets activated)
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Graphical login screen, defaulting to the Hyprland (UWSM) session
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    defaultSession = "hyprland-uwsm";
  };

  # Noctalia desktop shell, started automatically in the graphical session
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    recommendedServices.enable = true;
  };

  # Hint Electron/Chromium apps to use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.openssh.enable = true;
  environment.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake ~/projects/nixos-config#nixos";
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
