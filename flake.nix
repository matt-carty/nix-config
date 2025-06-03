{
  description = "Your new nix config";

  inputs = {
    # Nix ecosystem
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    systems.url = "github:nix-systems/default-linux";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Nix hardware
    hardware.url = "github:nixos/nixos-hardware";

    # Sops - not yet implemented
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nixvim to set up neovim
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Optional, if you intend to follow nvf's obsidian-nvim input
    # you must also add it as a flake input.
    obsidian-nvim.url = "github:epwalsh/obsidian.nvim";

    # Required, nvf works best and only directly supports flakes
    nvf = {
      url = "github:notashelf/nvf";
      # You can override the input nixpkgs to follow your system's
      # instance of nixpkgs. This is safe to do as nvf does not depend
      # on a binary cache.
      inputs.nixpkgs.follows = "nixpkgs";
      # Optionally, you can also override individual plugins
      # for example:
      inputs.obsidian-nvim.follows = "obsidian-nvim"; # <- this will use the obsidian-nvim from your inputs
    };
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    nvf,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      # Laptop for home
      alien = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
        };
        # > Our main nixos configuration file <
        modules = [./systems/alien/configuration.nix];
      };
      # NUC server for skippy
      razorback = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
        };
        # > Our main nixos configuration file <
        modules = [./systems/razorback/configuration.nix];
      };
      # RPi 4 file server at skippy
      behemoth = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
        };
        # > Our main nixos configuration file <
        modules = [./systems/behemoth/configuration.nix];
      };
      # RPi 4 server at skippy - maybe wont use
      bobbie = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
        };
        # > Our main nixos configuration file <
        modules = [./systems/bobbie/configuration.nix];
      };
      # RPi 3 server at skippy
      holden = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
        };
        # > Our main nixos configuration file <
        modules = [./systems/holden/configuration.nix];
      };
      # HP Z400 workstation at skippy  (main pc)
      medina = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
        };
        # > Our main nixos configuration file <
        modules = [
          nvf.nixosModules.default
          ./systems/medina/configuration.nix
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "matt@alien" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {
          inherit inputs outputs;
        };
        # > Our main home-manager configuration file <
        modules = [./home/matt/alien.nix];
      };
      "matt@razorback" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {
          inherit inputs outputs;
        };
        # > Our main home-manager configuration file <
        modules = [./home/matt/razorback.nix];
      };
      "matt@medina" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {
          inherit inputs outputs;
        };
        # > Our main home-manager configuration file <
        modules = [
          nvf.homeManagerModules.default
          ./home/matt/medina.nix
        ];
      };
      "matt@behemoth" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {
          inherit inputs outputs;
        };
        # > Our main home-manager configuration file <
        modules = [./home/matt/behemoth.nix];
      };
      "matt@bobbie" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {
          inherit inputs outputs;
        };
        # > Our main home-manager configuration file <
        modules = [./home/matt/bobbie.nix];
      };
      "matt@holden" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {
          inherit inputs outputs;
        };
        # > Our main home-manager configuration file <
        modules = [./home/matt/holden.nix];
      };
    };
  };
}
