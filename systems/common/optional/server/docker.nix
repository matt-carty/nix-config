{ ... }:
{
  virtualisation.docker.enable = true;
  users.users.matt.extraGroups = [ "docker" ];

  # Default json-file log driver has no cap, so long-running chatty
  # containers (Elasticsearch, Temporal, frigate) can quietly fill the disk.
  virtualisation.docker.daemon.settings = {
    "log-driver" = "json-file";
    "log-opts" = {
      "max-size" = "10m";
      "max-file" = "3";
    };
  };
}
