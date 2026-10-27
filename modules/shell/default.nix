# zsh as login shell, plus the CLI tools and integrations used interactively
{ pkgs, ... }:

{
  # The modules below add their init lines to interactive zsh
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

      # fnm: switch Node versions per project (.nvmrc / .node-version) on cd
      eval "$(${pkgs.fnm}/bin/fnm env --use-on-cd --shell zsh)"
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

  environment.systemPackages = with pkgs; [
    neovim
    fzf # used by fzf-tab
    lsd
    bat
    btop
    unzip
    zip
    yadm # dotfiles
  ];
}
