# Host identity specific to this machine (home desktop PC).
{...}: {
  imports = [../hardware/pc.nix];

  networking.hostName = "pc";
}
