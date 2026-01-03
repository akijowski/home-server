{ pkgs, lib, config, inputs, ... }:

let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.system;
    config.allowUnfree = true;
  };
in
{
  # needs to be a root (trusted) user to modify root nixos cache
  cachix.enable = true;

  delta.enable = true;
  # https://devenv.sh/basics/

  env = {
    # ansible inventory
    ANSIBLE_PROXMOX_TOKEN_SECRET = config.secretspec.secrets.ANSIBLE_PROXMOX_TOKEN_SECRET or "";
    # packer and ansible provisioning
    PACKER_PROXMOX_TOKEN_SECRET = config.secretspec.secrets.PACKER_PROXMOX_TOKEN_SECRET or "";
    # root required for specific proxmox actions
    PROXMOX_ROOT_PASSWORD = config.secretspec.secrets.PROXMOX_ROOT_PASSWORD or "";
  };

  dotenv.enable = true;

  # https://devenv.sh/packages/
  packages = [
    pkgs.go-task
    pkgs-unstable.packer
    pkgs-unstable.awscli2
    pkgs.pre-commit
    pkgs.hugo
  ];

  # https://devenv.sh/languages/
  # languages.rust.enable = true;
  languages = {
    python = {
      enable = true;
      venv.enable = true;
      venv.quiet = true;
      venv.requirements = ''
        ansible
        requests
        proxmoxer
        boto3
      '';
    };

    terraform = {
      enable = true;
      version = "1.14";
    };
  };

  # https://devenv.sh/processes/
  # processes.dev.exec = "${lib.getExe pkgs.watchexec} -n -- ls -la";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  # scripts.hello.exec = ''
  #   echo hello from $GREET
  # '';

  # https://devenv.sh/basics/
  enterShell = ''
  # https://github.com/cachix/devenv/issues/2323#issuecomment-3612165852
    export ANSIBLE_BECOME_PASSWORD_FILE=$(secretspec get ANSIBLE_BECOME_PASSWORD_FILE)
    export ANSIBLE_VAULT_PASSWORD_FILE=$(secretspec get ANSIBLE_VAULT_PASSWORD_FILE)
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  # enterTest = ''
  #   echo "Running tests"
  #   git --version | grep --color=auto "${pkgs.git.version}"
  # '';

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    check-json.enable = true;
    check-toml.enable = true;
    check-yaml = {
      enable = true;
      args = [ "--allow-multiple-documents" ];
    };
    check-added-large-files.enable = true;
    detect-private-keys.enable = true;
    end-of-file-fixer.enable = true;
    trim-trailing-whitespace.enable = true;
  };

  # See full reference at https://devenv.sh/reference/options/
}
