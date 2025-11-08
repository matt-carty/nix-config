{nixpkgs-stable, ...}: {
  environment.systemPackages = [
    nixpkgs-stable.input-leap
  ];
}
