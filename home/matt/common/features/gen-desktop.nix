
{ pkgs, ...}: {

  home.packages = with pkgs; [
    
   calibre 
   vlc
   remmina
   pdfslicer
   vial
  ];
programs.gnome-shell = {
  enable = true;
  extensions = [{ package = pkgs.gnomeExtensions.gsconnect; }];
};
}
