{config, ...}: {
  services.strongswan = {
    enable = true;

    secrets = [
      "eap-dukebk44.duckdns.org : EAP \"$(cat ${config.sops.secrets.ipsec_username.path}):$(cat ${config.sops.secrets.ipsec_password.path})\""
    ];

    ca.skippy-ca = {
      auto = "add";
      cacert = ./public_ipsec_certs/skippy_ipsec_ca.crt;
    };

    connections.pfsense-mobile = {
      keyexchange = "ikev2";
      remote_addrs = ["dukebk44.duckdns.org"];

      remote = {
        auth = "pubkey";
        id = "dukebk44.duckdns.org";
      };

      local = {
        auth = "eap";
        eap_id = "matt";
      };

      children.pfsense-tunnel = {
        # FULL TUNNEL: Route all traffic through VPN
        remote_ts = ["0.0.0.0/0"];

        esp_proposals = ["aes128-sha256-modp2048"];
        dpd_action = "restart";
        rekey_time = "60m";
        life_time = "66m";
      };

      ike_proposals = ["aes256gcm16-sha256-modp4096"];

      rekey_time = "480m";
      reauth_time = "0s";
      dpd_delay = "30s";
      dpd_timeout = "150s";
    };
  };

  sops.secrets.ipsec_username = {
    sopsFile = ../../../../secrets/secrets.yaml;
    owner = "root";
    mode = "0400";
  };

  sops.secrets."ipsec/password" = {
    sopsFile = ../../../../secrets/secrets.yaml;
    owner = "root";
    mode = "0400";
  };
}
