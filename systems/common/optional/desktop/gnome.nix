{ pkgs, ...}: {
  
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  
  # Packages primarily related to using gnome
  environment.systemPackages = with pkgs; [
   gnome-tweaks
   gnomeExtensions.smart-auto-move
   libheif

  ];

}
