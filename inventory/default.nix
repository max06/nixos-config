# Settings shared by every host, regardless of group.
{ lib, ... }:
{
  imports = [
    ../user
    ../system/common
  ];

  networking.useDHCP = lib.mkDefault true;

  time.timeZone = lib.mkDefault "Europe/Berlin";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  # German console keymap everywhere: LUKS passphrases and rescue shells are
  # typed on a German keyboard.
  console.keyMap = lib.mkDefault "de";

  # Larger download buffer avoids "download buffer is full" stalls on fast links.
  nix.settings.download-buffer-size = 512 * 1024 * 1024;

  # sops decrypts with an age key derived from the SSH host key. Set
  # explicitly: sops-nix only infers it when sshd is enabled, and the desktop
  # has the key but no sshd.
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
