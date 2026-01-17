{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "cursor" ''
      # Launch the latest cursor AppImage from Downloads
      DOWNLOADS_DIR="$HOME/Downloads"
      CURSOR=$(ls -t "$DOWNLOADS_DIR"/Cursor-*.AppImage 2>/dev/null | head -n1)

      if [ -n "$CURSOR" ]; then
        exec ${pkgs.appimage-run}/bin/appimage-run "$CURSOR" "$@"
      else
        echo "Error: No Cursor AppImage found in $DOWNLOADS_DIR" >&2
        echo "Please download Cursor from https://cursor.sh" >&2
        exit 1
      fi
    '')
  ];
}
