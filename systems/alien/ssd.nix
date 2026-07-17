# Repurpose the small mSATA SSD (sda) to speed up the machine without putting the
# nix store on it (which previously filled up and broke the system).
#
#   sda1 (ssdswap, 16G) -> swap, random-encrypted each boot (no hibernation)
#   sda2 (ssddata, rest) -> LUKS (keyfile on encrypted root) -> ext4, hosts
#                           /tmp (nix build scratch) and ~/.cache via bind mounts.
{ pkgs, ... }: {
  # --- Swap on the SSD (was previously none) -------------------------------
  swapDevices = [
    {
      device = "/dev/disk/by-partlabel/ssdswap";
      randomEncryption.enable = true;
    }
  ];

  # --- Unlock the encrypted data partition after the root fs is up ----------
  # Keyfile lives on the (LUKS-encrypted) root, so it is protected at rest.
  systemd.services.unlock-ssddata = {
    description = "Unlock SSD scratch/cache partition";
    wantedBy = [ "local-fs.target" ];
    before = [ "mnt-ssd.mount" ];
    after = [ "local-fs-pre.target" ];
    unitConfig.DefaultDependencies = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.cryptsetup}/bin/cryptsetup open --key-file /var/lib/ssd-luks.key /dev/disk/by-partlabel/ssddata cryptssd";
      ExecStop = "${pkgs.cryptsetup}/bin/cryptsetup close cryptssd";
    };
  };

  # --- Mount the SSD data fs, then bind /tmp and ~/.cache onto it -----------
  fileSystems."/mnt/ssd" = {
    device = "/dev/mapper/cryptssd";
    fsType = "ext4";
    options = [
      "nofail"
      "x-systemd.requires=unlock-ssddata.service"
      "x-systemd.after=unlock-ssddata.service"
    ];
  };

  fileSystems."/tmp" = {
    device = "/mnt/ssd/tmp";
    fsType = "none";
    depends = [ "/mnt/ssd" ];
    options = [ "bind" "nofail" ];
  };

  fileSystems."/home/matt/.cache" = {
    device = "/mnt/ssd/cache";
    fsType = "none";
    depends = [ "/mnt/ssd" ];
    options = [ "bind" "nofail" ];
  };

  # /tmp now lives on the SSD; clear it on boot so builds can't accumulate.
  boot.tmp.cleanOnBoot = true;
}
