{pkgs, ...}: {
  home.packages = with pkgs; [
    calibre
    vlc
    remmina
    pdfslicer
    vial
    appimage-run
  ];
  programs.gnome-shell = {
    enable = true;
    #  extensions = [{ package = pkgs.gnomeExtensions.gsconnect; }];
  };

  programs.bash.shellAliases = {
    cursor = "appimage-run /home/matt/appimage/Cursor-1.4.2-x86_64.AppImage";
  };
}
