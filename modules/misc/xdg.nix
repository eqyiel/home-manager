{ options, config, lib, pkgs, ... }:

with lib;

let

  cfg = config.xdg;

  fileType = basePath: (types.loaOf (types.submodule (
    { name, config, ... }: {
      options = {
        target = mkOption {
          type = types.str;
          apply = p: "${cfg.configHome}/${p}";
          description = ''
            Path to target file relative to <varname>${basePath}</varname>.
          '';
        };

        text = mkOption {
          default = null;
          type = types.nullOr types.lines;
          description = "Text of the file.";
        };

        source = mkOption {
          type = types.path;
          description = ''
            Path of the source file. The file name must not start
            with a period since Nix will not allow such names in
            the Nix store.
            </para><para>
            This may refer to a directory.
          '';
        };

        executable = mkOption {
          type = types.bool;
          default = false;
          description = "Make file executable.";
        };
      };

      config = {
        target = mkDefault name;
        source = mkIf (config.text != null) (
          let
            file = pkgs.writeTextFile {
              inherit (config) text executable;
              name = "user-etc-" + baseNameOf name;
            };
          in
            mkDefault file
        );
      };
    }
  )));

in

{
  options.xdg = {
    enable = mkEnableOption "management of XDG base directories";

    cacheHome = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.cache";
      defaultText = "$HOME/.cache";
      description = ''
        Absolute path to directory holding application caches.
      '';
    };

    configHome = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.config";
      defaultText = "$HOME/.config";
      description = ''
        Absolute path to directory holding application configurations.
      '';
    };

    dataHome = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.local/share";
      defaultText = "$HOME/.local/share";
      description = ''
        Absolute path to directory holding application data.
      '';
    };

    configFile = mkOption {
      type = fileType "xdg.configHome";
      default = {};
      description = ''
        Attribute set of files to link into the user's XDG
        configuration home.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      XDG_CACHE_HOME = cfg.cacheHome;
      XDG_CONFIG_HOME = cfg.configHome;
      XDG_DATA_HOME = cfg.dataHome;
    };

    home.file =
      let
        f = n: v: {
          inherit (v) source target;
          mode = if v.executable then "777" else "444";
        };
      in mapAttrsToList f cfg.configFile;
  };
}
