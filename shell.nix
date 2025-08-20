let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable";
  pkgs = import nixpkgs {};

  nixpkgs-pin = fetchTarball "https://github.com/NixOS/nixpkgs/archive/a71323f68d4377d12c04a5410e214495ec598d4c.tar.gz";
  pkgs-pin = import nixpkgs-pin {};

  packages = with pkgs; [
    git
    cacert
    gcc12 # Note: this also adds the `strip` utility.

    nimble
    nim_lk

    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXi
    libGL
    xorg.libXxf86vm
  ];

  removeCacheAlias = "rm-nimble";
  shellHook = let
    warn_nimble_dir = "Specifying the NIMBLE_DIR env might cause inconsistent behaviour, it is currently set to: $NIMBLE_DIR";
    warn_submodules = "IMPORTANT: incorrect or missing submodules might cause compiler errors!" +
      " If you are cloning with git, append \\`--recursive\\`" +
      " If you are cloning with gh, append \\`-- --recursive\\`";
  in ''
    NIMBLE_PATH=""
    HAS_CACHE=false
    CACHE_PATH=""

    if [ -d "$NIMBLE_DIR" ]; then
      echo "${warn_nimble_dir}"
      NIMBLE_PATH="$NIMBLE_DIR"
    else
      NIMBLE_PATH="/home/$(whoami)/.nimble"
    fi
    export PATH="$PATH:$NIMBLE_PATH/bin"
    CACHE_PATH="$NIMBLE_PATH/pkgcache"
    [ ! -d "$CACHE_PATH" ] && HAS_CACHE=true

    RM="rm -rf \"$CACHE_PATH\"";
    alias ${removeCacheAlias}="echo \"$RM\" && $RM"

    [ "$(find fau -maxdepth 1 -type f | wc -l)" == "0" ] && echo "${warn_submodules}"

    export LD_LIBRARY_PATH=${ with pkgs; lib.makeLibraryPath [
        libpulseaudio
      ]
    }
  '';

  lin = with pkgs; mkShellNoCC {
    # Note: different distributions of nim are separated across shell
    # environments to avoid the wrong CPU backend being chosen.
    packages = packages ++ [ pkgs-pin.nim ];

    shellHook = let
      warn_cache = "Inconsistent behaviour might happen because of the existing Nimble cache at $CACHE_PATH; " +
        "To quickly delete it permanently, run: \\`${removeCacheAlias}\\` (WARNING: any loss are at your own risk)";
    in shellHook + "\n" + ''
      [ "$HAS_CACHE" == "false" ] && echo "${warn_cache}"
    '';
  };

in {
  inherit lin;
  default = lin;

  # Not tested on branch "v1.2-revive":
  # win = with pkgs; let
  #   cross = with pkgsCross.mingwW64.buildPackages; [
  #     gcc12
  #     pkgs-pin.nim
  #   ];
  #   compatibility = [
  #     wine64
  #     winetricks
  #   ];
  # in { wineprefix ? "~/.local/share/wineprefixes/animdustry" }: mkShellNoCC {
  #   packages = packages ++ cross ++ compatibility;
  #
  #   shellHook = let
  #     warn_cross_fau = "Faupack should be compiled and installed for your host before cross-compiling Animdustry."
  #       + " If you do not mean to cross-compile, please enter the default shell with: \\`nix-shell -A default\\`";
  #   in shellHook + "\n" + ''
  #     SYMLINK="$NIMBLE_PATH/bin/faupack"
  #     [ ! -f "$(realpath --quiet $SYMLINK)" ] && echo "${warn_cross_fau}";
  #
  #     export WINEPREFIX="$(realpath ${wineprefix})"
  #     export WINE="wine64"
  #   '';
  # };
}

