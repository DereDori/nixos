# Host identity and hardware quirks specific to this machine (HP laptop).
{...}: {
  imports = [../hardware/hp.nix];

  networking.hostName = "hp";

  boot.extraModprobeConfig = ''
    options snd-hda-intel model=17aa:2288
  '';

  # Fix Elan touchpad/TrackPoint interval lag introduced by a BIOS/EC firmware
  # update (applied via Fedora's fwupd; persists in hardware, so it lags on any
  # OS). Both internal pointers share I2C client 0-0015 on the shared i801
  # SMBus that the EC also polls; the firmware change made that path stutter.
  # This forces the touchpad to stay in PS/2 mode instead of upgrading to SMBus,
  # bypassing the contended bus. A Bluetooth mouse is unaffected (separate USB
  # radio). Trade-off: PS/2 mode drops some high-res multitouch gestures.
  boot.kernelParams = ["psmouse.elantech_smbus=0"];
}
