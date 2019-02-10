{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let
version = "0.0.1";

in {
        dmenu_pass = stdenv.mkDerivation rec {
                name = "dmenu_pass-${version}";

                src = ./.;
                unpackCmd = '''';

                buildInputs = [stdenv pass xdotool];

                nativeBuildInputs = [makeWrapper];

                installPhase = ''
                  mkdir -p $out/bin
                  cp dmenu_pass.sh $out/bin/
                  chmod +x $out/bin/dmenu_pass.sh
                  wrapProgram $out/bin/dmenu_pass.sh --prefix PATH ":" ${xdotool}
                '';
        };
}
