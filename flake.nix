{
  description = "My NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Stable channel for individual packages that are broken on unstable
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Encrypted secrets (secrets/secrets.yaml), decrypted at activation
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      sops-nix,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          pkgs-stable = nixpkgs-stable.legacyPackages.${system};
        };
        modules = [
          ./hosts/nixos
          sops-nix.nixosModules.sops
        ];
      };
    };
}
