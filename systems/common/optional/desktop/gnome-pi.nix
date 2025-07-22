{pkgs, ...}: {
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  #  services.xserver.displayManager.lightdm.enable = true;
  #  services.xserver.desktopManager.gnome.enable = true;
  #  services.xserver.videoDriver = "fbdev";
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.desktopManager.xfce.enable = true;
  services.displayManager.defaultSession = "xfce";
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
