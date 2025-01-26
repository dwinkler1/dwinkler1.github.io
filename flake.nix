{
  description = "Quarto website build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        reqs = with pkgs; [
          quarto
        ];
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "personal website";
          src = ./.;

          buildInputs = reqs;

          buildPhase = ''
            mkdir home
            export HOME=$PWD/home
            quarto render
          '';

          installPhase = ''
            mkdir -p $out
            cp -r build/* $out/
          '';
        };

        devShells.default = pkgs.mkShell {
          buildInputs = reqs;
        };
      });
}