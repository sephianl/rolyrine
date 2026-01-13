{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  system = "x86_64-linux";
in
{
  process.managers.process-compose.tui.enable = false;
  cachix.enable = false;

  languages = {
    elixir = {
      enable = true;
      package = pkgs.elixir_1_19;
    };
        rust = {
      enable = true;
    };
  };

  packages =
    with pkgs;
    [
      gh
      nixfmt-rfc-style
    ];
}
