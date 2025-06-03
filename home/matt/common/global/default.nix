{
  inputs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    inputs.nixvim.homeManagerModules.nixvim
    # inputs.nix-colors.homeManagerModule
#    ./nvim
    ./git.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # Set your username
  home = {
    username = "matt";
    homeDirectory = "/home/matt";
  };

  # Packages that will be on all systems for Matt only
  #home.packages = with pkgs; [ rustlings ];
  programs.kitty = {
    enable = true;
    # theme = "Rosé Pine";
    themeFile = "rose-pine";
    settings = {
      # Workaround for nerd fonts being broken: font_family = "Fira Code Nerd Font Mono";
      font_family = "monospace";
    };
   };

  programs.direnv = {
      enable = true;
      enableBashIntegration = true; #TODO: Change to zsh if I change shells (likely) 
      nix-direnv.enable = true;
  };

  # bash config here - aliases for all systems too
  programs.bash = {
    enable = true;
    shellAliases = {
    hms = "home-manager switch --flake .#$(whoami)@$(hostname)";
    nrs = "sudo nixos-rebuild switch --flake .#$(hostname)";
    cd = "z";
    ssk = "kitten ssh";
    raz = "ssk razorback";

    };
    bashrcExtra = ''eval "$(zoxide init bash)"'';
  };

  # ssh config here
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "draper" = {
	user = "root";
      };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
