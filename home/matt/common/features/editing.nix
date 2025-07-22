{ pkgs, ...}: {

  home.packages = with pkgs; [
    
    inkscape
    gimp
    kdePackages.kdenlive
    scribus
    digikam
    texliveMedium
  ];
}
