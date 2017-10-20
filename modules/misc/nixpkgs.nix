{ config, lib, pkgs, ... }:

with lib;

let

  nixpkgsModule = import <nixpkgs/nixos/modules/misc/nixpkgs.nix> {
    inherit lib pkgs;
    config.nixpkgs = removeAttrs config.nixpkgs [ "enable" ];
  };

in

{
  # We reuse the options from the NixOS module but we remove the
  # `system` attribute since it is not particularly relevant for a
  # user environment. We also add an `enable` option to allow the user
  # to decide whether Home Manager should manage the Nixpkgs
  # configuration.
  options = {
    nixpkgs =
      removeAttrs nixpkgsModule.options.nixpkgs [ "system" ]
      // {
        enable = mkEnableOption "management of Nixpkgs configuration";
      };
  };

  config = mkIf config.nixpkgs.enable (nixpkgsModule.config);
}
