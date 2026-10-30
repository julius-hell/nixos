{ pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  # Run unpatched prebuilt binaries (npm deps like esbuild/playwright, nvm-style downloads)
  programs.nix-ld.enable = true;

  environment.shellAliases = {
    rebuild = ''find "$HOME/projects/nixos-config" -type f -name '*.nix' -exec ${pkgs.nixfmt}/bin/nixfmt {} + && sudo nixos-rebuild switch --flake "$HOME/projects/nixos-config#nixos"'';
  };
}
