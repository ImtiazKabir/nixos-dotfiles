{
  description = "stupid flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager } @inputs:
  let 
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        (import ./overlays/dwm.nix)
        (import ./overlays/slstatus.nix)
      ];
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.milkiway = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./nixos/configuration.nix
        { nixpkgs.pkgs = pkgs; }
      ];
      specialArgs = { inherit inputs; };
    };

    homeConfigurations = {
      "sol@milkiway" = home-manager.lib.homeManagerConfiguration {
        # pkgs = nixpkgs.legacyPackages.x86_64-linux;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import ./overlays/dwm.nix)
            (import ./overlays/slstatus.nix)
          ];
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home-manager/home.nix ];
      };
    };
  };

}
