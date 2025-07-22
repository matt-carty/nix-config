{ ... }:{


  fileSystems."/home" =
    { device = "/dev/mapper/luks-ada88174-45a8-428c-b551-5c26943426ef";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-ada88174-45a8-428c-b551-5c26943426ef".device = "/dev/disk/by-uuid/ada88174-45a8-428c-b551-5c26943426ef";
  }
