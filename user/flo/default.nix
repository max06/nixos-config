# NixOS-side account for flo. Applied on every host that lists "flo" in
# `hostUsers`. The home-manager side lives in ./home.nix and is attached by
# the desktop group only.
{
  config,
  lib,
  ...
}:
let
  # The login password comes from sops (secrets/users.yaml). Until that file
  # exists the option is left unset: existing hosts keep the password already
  # stored in /etc/shadow (users.mutableUsers defaults to true), and a fresh
  # install is reachable via SSH key only.
  usersSecretsFile = ../../secrets/users.yaml;
  haveUsersSecrets = builtins.pathExists usersSecretsFile;
in
{
  options.hostUsers = lib.mkOption {
    type = with lib.types; listOf (enum [ "flo" ]);
  };

  config = lib.mkIf (builtins.elem "flo" config.hostUsers) {
    users.users.flo = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = import ./keys.nix;
      hashedPasswordFile = lib.mkIf haveUsersSecrets config.sops.secrets."flo/hashed-password".path;
    };

    sops.secrets."flo/hashed-password" = lib.mkIf haveUsersSecrets {
      sopsFile = usersSecretsFile;
      neededForUsers = true;
    };

    # Needed for remote deployments (nixos-rebuild --target-host) and nh.
    nix.settings.trusted-users = [ "flo" ];

    programs.fish.enable = true;

    # keybase-gui ships an end-of-life Electron; still wanted.
    nixpkgs.config.permittedInsecurePackages = [ "keybase-gui-6.5.1" ];
  };
}
