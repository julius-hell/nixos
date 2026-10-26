{ ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  # Run unpatched prebuilt binaries (npm deps like esbuild/playwright, nvm-style downloads)
  programs.nix-ld.enable = true;

  environment.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake ~/projects/nixos-config#nixos";
  };
}
