{...}: {
  # Enable Open WebUI service
  services.open-webui = {
    enable = true;

    # Change port from default 8080 to your desired port
    port = 3001; # Change this to whatever port you want (not 3000)

    # Optional: Set host (default is 127.0.0.1)
    host = "127.0.0.1";

    # Optional: Open firewall for this port if you need external access
    # openFirewall = true;

    # Set environment variables for Open WebUI
    environment = {
      # Disable telemetry
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";

      # If using OpenAI-compatible API, set it here
      # OPENAI_API_BASE_URL = "https://api.openai.com/v1";
      # OPENAI_API_KEY = "your-api-key";  # Better to use secrets management

      # Or if using another compatible backend
      # OPENAI_API_BASE_URL = "http://your-llm-server:port/v1";
    };

    # The stateDir option sets where data is stored
    # Default is /var/lib/open-webui which should work properly
    stateDir = "/var/lib/open-webui";
  };
}
