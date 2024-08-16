{
  description = "My NixOS configuration";

  nixConfig = {
#    extra-substituters = [
#      "https://cache.m7.rs"
#      "https://nix-gaming.cachix.org"
#    ];
#    extra-trusted-public-keys = [
#      "cache.m7.rs:kszZ/NSwE/TjhOcPPQ16IuUiuRSisdiIwhKZCxguaWg="
#      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
#    ];
  };

  inputs = {
    # Nix ecosystem
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    systems.url = "github:nix-systems/default-linux";

    hardware.url = "github:nixos/nixos-hardware";
    # impermanence.url = "github:nix-community/impermanence";
 #   impermanence.url = "github:misterio77/impermanence";
    nix-colors.url = "github:misterio77/nix-colors";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-24_05.follows = "nixpkgs-stable";
    };
    nix-gl = {
      url = "github:nix-community/nixgl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Third party programs, packaged with nix
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    systems,
    ...
  } @ inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib // home-manager.lib;
    forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs (import systems) (
      system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
    );
  in {
    inherit lib;
 #   nixosModules = import ./modules/nixos;
 #   homeManagerModules = import ./modules/home-manager;

 #   overlays = import ./overlays {inherit inputs outputs;};
 #   hydraJobs = import ./hydra.nix {inherit inputs outputs;};

 #   packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});
 #   devShells = forEachSystem (pkgs: import ./shell.nix {inherit pkgs;});
 #   formatter = forEachSystem (pkgs: pkgs.alejandra);

    nixosConfigurations = {
      # Main desktop
      alien = lib.nixosSystem {
        modules = [./hosts/alien];
        specialArgs = {
          inherit inputs outputs;
        };
      };
      # Secondary desktop
      homevm = lib.nixosSystem {
        modules = [./hosts/homevm];
        specialArgs = {
          inherit inputs outputs;
        };
      };
    };

    homeConfigurations = {
      # Standalone HM only
      # Work laptop
      "matt@alien" = lib.homeManagerConfiguration {
        modules = [ ./home/matt/alien.nix ./home/matt/nixpkgs.nix ];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs outputs;
        };
      };

      # Main desktop
      "matt@homevm" = lib.homeManagerConfiguration {
        modules = [./home/matt/homevm.nix ./home/matt/nixpkgs.nix];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs outputs;
        };
      };
    };
  };
}
