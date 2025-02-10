{ pkgs, ...}: {
  
#  environment.systemPackages = with pkgs; [
#    nerdfonts

 # ];

  environment.systemPackages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    ];

  # Enable fonts to use on your system.  You should make sure to add at least
  # one English font (like dejavu_fonts), as well as Japanese fonts like
  # "ipafont" and "kochi-substitute".
  fonts.packages = with pkgs; [
    carlito
    dejavu_fonts
    ipafont
    kochi-substitute
    source-code-pro
    ttf_bitstream_vera
    (google-fonts.override { fonts = [ "MPLUS1Code" "MouseMemoirs" "Lobster" "ZenKakuGothicNew" "NotoSans" "NotoSerifJP" "WorkSans" "Inter" "Archivo" "Prompt"]; })
#    (nerd-fonts.override { fonts = [ "FiraCode" "DroidSansMono" "JetBrainsMono" ]; })
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    fira-code
  ];

  fonts.fontDir.enable = true;
  fonts.fontconfig.enable = true;
  # These settings enable default fonts for your system.  This setting is very
  # important.  It lets fontconfig know that you want to fall back to a Japanese
  # font (for example "IPAGothic") if an application tries to show fonts with
  # Japanese.  For instance, this is important if you are using a terminal
  # emulator and you `cat` some Japanese text to the screen. If you don't have
  # "defaultFonts" configured, fontconfig will pick a random Japanese font to
  # use.  If you have this "defaultFonts" setting configured, fontconfig will
  # pick the font you have selected.  This makes sure Japanese fonts look nice.
  fonts.fontconfig.defaultFonts = {
    monospace = [
      "FiraCode"
      "M PLUS 1 Code"
    ];
    sansSerif = [
      "DejaVu Sans"
      "Zen Kaku Gothic New"
    ];
    serif = [
      "DejaVu Serif"
      "Noto Serif Japanese"
    ];
  };


  # This enables "fcitx" as your IME.  This is an easy-to-use IME.  It supports many different input methods.
  i18n.inputMethod = {
    type = "ibus";
    enable = true;
    ibus.engines = with pkgs.ibus-engines; [ hangul mozc ];
  };

}
