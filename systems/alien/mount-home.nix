{ ... }:{

fileSystems."/home" =
    { device = "/dev/disk/by-uuid/86745910-5dfc-4038-93ae-00c3ec6ef566";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-e15f276f-164f-4619-b3df-dd5593629fb4".device = "/dev/disk/by-uuid/e15f276f-164f-4619-b3df-dd5593629fb4";
}
