let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable";
  pkgs = import nixpkgs {};

  packages = with pkgs; [
    git
    cacert
    gcc

    nimble
    nim_lk

    # nim

    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXi
    libGL
    xorg.libXxf86vm
  ];

  shellHook = let
    warn_nimble_dir = "Specifying the NIMBLE_DIR env might cause inconsistent behaviour, it is currently set to: $NIMBLE_DIR";
    warn_cache = "Existing Nimble cache might cause inconsistent behaviour: $CACHE_PATH";
    warn_submodules = "IMPORTANT: incorrect or missing submodules might cause compiler errors!" +
      " If you are cloning with git, append \\`--recursive\\`" +
      " If you are cloning with gh, append \\`-- --recursive\\`";
  in ''
    CACHE_PATH=""

    if [ -d "$NIMBLE_DIR" ]; then
      export PATH="$PATH:/home/$NIMBLE_DIR/bin" echo ${warn_nimble_dir}

      CACHE_PATH="$NIMBLE_DIR/pkgcache"
      [ -d "$CACHE_PATH" ] || CACHE_PATH=""
    else
      DEFAULT_NIMBLE_DIR="/home/$(whoami)/.nimble"
      export PATH="$PATH:$DEFAULT_NIMBLE_DIR/bin"

      CACHE_PATH="$DEFAULT_NIMBLE_DIR/pkgcache"
      [ -d "$CACHE_PATH" ] || CACHE_PATH=""
    fi

    [ "$CACHE_PATH" == "" ] || echo ${warn_cache}
    [ "$(find fau -maxdepth 1 -type f | wc -l)" == "0" ] && echo ${warn_submodules}
  '';

  lin = with pkgs; mkShellNoCC {
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
