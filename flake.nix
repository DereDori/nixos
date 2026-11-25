{
  description = "thefool's NixOS configuration";

  inputs = {
    # Track the 25.11 release. Bump this string to move releases.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # `follows` keeps home-manager on the SAME nixpkgs as the system,
    # so there's no version skew between the two.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    # Builds one nixosConfiguration for a given host (hardware + identity,
    # from ./hosts/<host>.nix), primary user, and desktop module (gnome or
    # hyprland). `./modules` is shared across every host and desktop choice.
    mkHost = host: username: desktopModule:
      nixpkgs.lib.nixosSystem {
        inherit system;
        # specialArgs makes `inputs` and `username` available to every module.
        specialArgs = {inherit inputs username;};
        modules = [
          ./hosts/${host}.nix
          desktopModule
          ./modules
          home-manager.nixosModules.home-manager
        ];
      };
  in {
    nixosConfigurations = {
      hp = mkHost "hp" "thefool" ./modules/desktop.nix;
      "hp-hyprland" = mkHost "hp" "thefool" ./modules/hyprland.nix;
      pc = mkHost "pc" "thetower" ./modules/desktop.nix;
      "pc-hyprland" = mkHost "pc" "thetower" ./modules/hyprland.nix;
    };

    templates.default = self.templates.rust;

    templates.rust = {
      path = ./templates/rust;
      description = "Per-project Rust devshell (fenix): pinned toolchain, rust-analyzer, direnv";
    };

    # `nix fmt` formats the whole repo.
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;

    nix.settings.allow-unfree = true;
  };
}
