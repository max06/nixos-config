# Logitech wireless receivers (Solaar) and an MX Master 3 quirk.
{ lib, ... }:
{
  hardware.logitech.wireless.enable = true;
  programs.solaar.enable = true;

  # Disable high-resolution wheel events: they make the MX Master 3 scroll
  # erratically under libinput.
  environment.etc."libinput/local-overrides.quirks".text = lib.mkForce ''
    [Logitech MX Master 3]
    MatchName=*Logitech MX Master 3*
    AttrEventCode=-REL_WHEEL_HI_RES;-REL_HWHEEL_HI_RES;
  '';
}
