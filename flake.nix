{
  description = "Report for the first lab of the cryptography on hardware course at university darmstadt";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        name = "tud-cryptography-on-hardware-lab-1";

        devShell = pkgs.mkShell {
          nativeBuildInputs = [
            (pkgs.python3.withPackages
              (python-pkgs: [
                python-pkgs.edalize
                python-pkgs.cocotb
                python-pkgs.cocotb-bus
              ]))
            pkgs.ghdl
            pkgs.verilator
          ];
        };
      }
    );
}
