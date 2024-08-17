{
  pkgs,
  ...
}: {
  imports = [
    ./global/default.nix
    ./global/features/editing.nix
  ];
}
