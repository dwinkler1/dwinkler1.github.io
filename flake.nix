{
  description = "Quarto website build";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = f:
      builtins.listToAttrs (map (system: {
          name = system;
          value = f (builtins.getAttr system nixpkgs.legacyPackages);
        })
        systems);
    reqPkgs = pkgs: [pkgs.quarto];
  in {
    packages = forAllSystems (
      pkgs: let
        website = pkgs.stdenv.mkDerivation {
          name = "personal-website";
          src = ./.;

          buildInputs = reqPkgs pkgs;

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
      in {
        default = website;
      }
    );

    devShells = forAllSystems (
      pkgs: {
        default = pkgs.mkShell {
          buildInputs = reqPkgs pkgs;
        };
      }
    );
  };
}
