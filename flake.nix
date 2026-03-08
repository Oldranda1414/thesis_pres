{
  description = "Dev environment for seven wonders hobby project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  };

  outputs = { self , nixpkgs ,... }: let
    system = "x86_64-linux";
  in {
    devShells."${system}".default = let
      pkgs = import nixpkgs {
        inherit system;
      };
    in pkgs.mkShell {
      packages = with pkgs; [
        # modern command runner
        just
      ];

      shellHook = ''
        echo "Run 'just' to see available commands."
      '';
    };
  };
}
