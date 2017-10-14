{ pkgs
, lib

  # Whether to enable module type checking.
, check ? true

  # Whether these modules are inside a NixOS submodule.
, nixosSubmodule ? false
}:

with lib;

let

  modules = [
    ./home-environment.nix
    ./files.nix
    ./manual.nix
    ./misc/fontconfig.nix
    ./misc/gtk.nix
    ./misc/news.nix
    ./misc/pam.nix
    ./programs/bash.nix
    ./programs/beets.nix
    ./programs/browserpass.nix
    ./programs/command-not-found/command-not-found.nix
    ./programs/eclipse.nix
    ./programs/emacs.nix
    ./programs/feh.nix
    ./programs/firefox.nix
    ./programs/git.nix
    ./programs/gnome-terminal.nix
    ./programs/home-manager.nix
    ./programs/htop.nix
    ./programs/info.nix
    ./programs/lesspipe.nix
    ./programs/man.nix
    ./programs/rofi.nix
    ./programs/ssh.nix
    ./programs/termite.nix
    ./programs/texlive.nix
    ./programs/vim.nix
    ./programs/zsh.nix
    ./services/blueman-applet.nix
    ./services/compton.nix
    ./services/dunst.nix
    ./services/gnome-keyring.nix
    ./services/gpg-agent.nix
    ./services/keepassx.nix
    ./services/network-manager-applet.nix
    ./services/owncloud-client.nix
    ./services/polybar.nix
    ./services/random-background.nix
    ./services/redshift.nix
    ./services/screen-locker.nix
    ./services/syncthing.nix
    ./services/taffybar.nix
    ./services/tahoe-lafs.nix
    ./services/udiskie.nix
    ./services/xscreensaver.nix
    ./systemd.nix
    ./xresources.nix
    ./xsession.nix
    <nixpkgs/nixos/modules/misc/assertions.nix>
    <nixpkgs/nixos/modules/misc/meta.nix>
  ];

  pkgsModule = {
    options.nixosSubmodule = mkOption {
      type = types.bool;
      internal = true;
      readOnly = true;
    };

    config.nixosSubmodule = nixosSubmodule;
    config._module.args.pkgs = mkForce pkgs;
    config._module.args.baseModules = modules;
    config._module.check = check;
  };

in

  map import modules ++ [ pkgsModule ]
