{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.vlagent;

  startCLIList =
    [
      "${cfg.package}/bin/vlagent"
    ]
    ++ lib.optionals (cfg.remoteWrite.url != null) [
      "-remoteWrite.url=${cfg.remoteWrite.url}"
      "-remoteWrite.tmpDataPath=%C/vlagent/remote_write_tmp"
    ]
    ++ lib.optional (
      cfg.remoteWrite.basicAuthUsername != null
    ) "-remoteWrite.basicAuth.username=${cfg.remoteWrite.basicAuthUsername}"
    ++ lib.optional (
      cfg.remoteWrite.basicAuthPasswordFile != null
    ) "-remoteWrite.basicAuth.passwordFile=\${CREDENTIALS_DIRECTORY}/remote_write_basic_auth_password"
    ++ cfg.extraArgs;

in
{
  options.services.vlagent = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable VictoriaMetrics's `vlagent`.

        `vlagent` is a tiny agent which helps you collect logs from various sources and store them in VictoriaLogs .
      '';
    };

    package = lib.mkPackageOption pkgs "vlagent" { };

    remoteWrite = {
      url = lib.mkOption {
        default = null;
        type = lib.types.nullOr lib.types.str;
        description = ''
          Endpoint for prometheus compatible remote_write
        '';
      };
      basicAuthUsername = lib.mkOption {
        default = null;
        type = lib.types.nullOr lib.types.str;
        description = ''
          Basic Auth username used to connect to remote_write endpoint
        '';
      };
      basicAuthPasswordFile = lib.mkOption {
        default = null;
        type = lib.types.nullOr lib.types.str;
        description = ''
          File that contains the Basic Auth password used to connect to remote_write endpoint
        '';
      };
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to open the firewall for the default ports.
      '';
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Extra args to pass to `vlagent`. See the docs:
        <https://docs.victoriametrics.com/vlagent.html#advanced-usage>
        or {command}`vlagent -help` for more information.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ 9429 ];

    systemd.services.vlagent = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "vlagent system service";
      serviceConfig = {
        DynamicUser = true;
        User = "vlagent";
        Group = "vlagent";
        Type = "simple";
        Restart = "on-failure";
        CacheDirectory = "vlagent";
        ExecStart = lib.escapeShellArgs startCLIList;
        LoadCredential = lib.optional (cfg.remoteWrite.basicAuthPasswordFile != null) [
          "remote_write_basic_auth_password:${cfg.remoteWrite.basicAuthPasswordFile}"
        ];
      };
    };
  };
}
