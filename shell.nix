let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable";
  pkgs = import nixpkgs {};

  packages = with pkgs; [
    git
    cacert
    gcc # Note: this also adds the `strip` utility.

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

  shellHook = let
    removeCacheAlias = "rm-nimble";
    warn_nimble_dir = "Specifying the NIMBLE_DIR env might cause inconsistent behaviour, it is currently set to: $NIMBLE_DIR";
    warn_cache = "Inconsistent behaviour might happen because of the existing Nimble cache at $CACHE_PATH; " +
      "To quickly delete it permanently, run: ${removeCacheAlias} (any loss are at your own risk)";
    warn_submodules = "IMPORTANT: incorrect or missing submodules might cause compiler errors!" +
      " If you are cloning with git, append \\`--recursive\\`" +
      " If you are cloning with gh, append \\`-- --recursive\\`";
  in ''
    HAS_CACHE=false
    CACHE_PATH=""

    if [ -d "$NIMBLE_DIR" ]; then
      export PATH="$PATH:/home/$NIMBLE_DIR/bin" echo "${warn_nimble_dir}"

      CACHE_PATH="$NIMBLE_DIR/pkgcache"
      [ -d "$CACHE_PATH" ] || HAS_CACHE=true
    else
      DEFAULT_NIMBLE_DIR="/home/$(whoami)/.nimble"
      export PATH="$PATH:$DEFAULT_NIMBLE_DIR/bin"

      CACHE_PATH="$DEFAULT_NIMBLE_DIR/pkgcache"
      [ -d "$CACHE_PATH" ] || HAS_CACHE=true
    fi
    RM="rm -rf \"$CACHE_PATH\"";
    alias ${removeCacheAlias}="echo \"$RM\" && $RM"

    [ "$HAS_CACHE" == "true" ] || echo "${warn_cache}"
    [ "$(find fau -maxdepth 1 -type f | wc -l)" == "0" ] && echo "${warn_submodules}"

    export LD_LIBRARY_PATH=${ with pkgs; lib.makeLibraryPath [
        libpulseaudio
      ]
    }
  '';

  lin = with pkgs; mkShellNoCC {
    # Note: different distributions of nim are separated across shell
    # environments to avoid the wrong CPU backend being chosen.
    packages = packages ++ [ nim ];

    inherit shellHook;
  };

in {
  inherit lin;
  default = lin;

  win = with pkgs; let
    cross = with pkgsCross.mingwW64.buildPackages; [
      gcc
      nim
    ];
    compatibility = [
      wine64
      winetricks
    ];
  in { wineprefix ? "~/.local/share/wineprefixes/animdustry" }: mkShellNoCC {
    packages = packages ++ cross ++ compatibility;

    shellHook = shellHook + "\n" + ''
      export WINEPREFIX="$(realpath ${wineprefix})"
      export WINE="wine64"
    '';
  };
}
