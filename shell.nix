{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "geoname-sprint-dev";

  packages = with pkgs; [
    ruby_4_0
    foreman

    postgresql
    libpq

    pkg-config
    libyaml
    openssl
    readline
    libffi
    zlib

    git
    gnumake
    gcc
  ];

  shellHook = ''
    export GEM_HOME="$PWD/.nix-gems"
    export GEM_PATH="$GEM_HOME"
    export BUNDLE_PATH="$PWD/vendor/bundle"
    export BUNDLE_BIN="$PWD/bin"
    export PATH="$GEM_HOME/bin:$BUNDLE_BIN:$PATH"

    export PG_CONFIG=${pkgs.libpq}/bin/pg_config

    echo "Geoname Sprint development environment loaded."
    echo "Ruby: $(ruby --version)"
    echo "Bundler: $(bundle --version)"
  '';
}
