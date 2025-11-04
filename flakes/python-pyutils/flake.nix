{
    description = "A flake to manage python dependencies";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs =
        { self, nixpkgs, flake-utils, ... }:
        flake-utils.lib.eachDefaultSystem(system:
            let
                # Define the packages for our system
                pkgs = nixpkgs.legacyPackages.${system};
                # set current version of python to 3.13
                python = pkgs.python313;
            in
            {
                # set the default output to a python environment using withPackages
                packages.default = python.withPackages (
                    # ps = pythonPackages
                    # with ps; aliases the variable so we no longer need to define it like 'ps.<pip package name>'
                    ps: with ps;
                    [
                        ansible-core
                        proxmoxer
                        boto3
                        hvac
                        dnspython
                    ]
                );

            }
        );
}
