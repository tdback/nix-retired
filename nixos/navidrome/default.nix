{ ... }:
let
  directory = "/opt/navidrome";
in
{
  systemd.tmpfiles.rules = builtins.map (x: "d ${x} 0755 share share - -") [ directory ];

  virtualisation.oci-containers.containers.navidrome = {
    image = "deluan/navidrome:latest";
    autoStart = true;
    ports = [
      "4533:4533"
    ];
    volumes = [
      "${directory}/data:/data"
      "/tank/media/music:/music:ro"
    ];
    environment = {
      ND_SCANSCHEDULE = "1h";
      ND_LOGLEVEL = "info";
      ND_SESSIONTIMEOUT = "24h";
      ND_ENABLEUSEREDITING = "false";
    };
  };

  services.caddy.virtualHosts."radioactive.brownbread.net".extraConfig = ''
    encode zstd gzip
    reverse_proxy http://localhost:4533
  '';
}
