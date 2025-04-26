{ ... }: {

environment.etc.crypttab.text =
''luks-48a66bfc-3bb1-4a2b-8244-c2a04fc4fcac UUID=48a66bfc-3bb1-4a2b-8244-c2a04fc4fcac /etc/luks-keys/luks-48a66bfc-3bb1-4a2b-8244-c2a04fc4fcac nofail
'';
fileSystems = {
  "/mnt/ssd" = {
    device = "/dev/mapper/luks-48a66bfc-3bb1-4a2b-8244-c2a04fc4fcac";
    fsType = "ext4";
    options = [ "nofail"
		"rw"
		"nosuid"
		"uhelper=udisks2"];
  };
}
;
}
