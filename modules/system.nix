# Core system: boot, nix, users, networking, locale, time, git.
# Host identity and hardware quirks live in ../hosts/*.nix, not here.
{
  pkgs,
  username,
  ...
}: {
  system.stateVersion = "26.05";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Show the generation picker for a few seconds on every boot instead of
  # jumping straight to the default entry, so a broken generation can be
  # escaped by booting the previous one instead of needing rescue access.
  boot.loader.timeout = 3;

  # Root is locked (no password) by default on NixOS, which turns any drop
  # into emergency/rescue mode into an unrecoverable "Login incorrect" loop
  # at the password prompt. Point at a hash file outside the repo (this repo
  # is public) so recovery is possible without publishing a crackable hash.
  # Create it once per machine with:
  #   sudo install -d -m 700 /etc/nixos-secrets
  #   mkpasswd -m sha-512 | sudo tee /etc/nixos-secrets/root.hash >/dev/null
  #   sudo chmod 600 /etc/nixos-secrets/root.hash
  users.users.root.hashedPasswordFile = "/etc/nixos-secrets/root.hash";

  nixpkgs.config.allowUnfree = true;

  # Networking
  networking.networkmanager.enable = true;

  # Nix daemon settings
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "12:00";
    options = "--delete-older-than 7d";
  };

  # Daily auto-upgrade FROM the flake on GitHub. This replaces the old
  # every-minute git-pull + rebuild timers. It rebuilds at 06:00 using
  # whatever is committed to main (and its flake.lock), catching up on the
  # next boot if the machine was off. To pull in new nixpkgs, run
  # `nix flake update` locally and push (or run ./rebuild.sh).
  system.autoUpgrade = {
    enable = true;
    flake = "github:deredori/nixos";
    dates = "06:00";
    operation = "boot";
    persistent = true;
    allowReboot = false;
  };

  # Time & locale
  time.timeZone = "Europe/Vienna";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  # User
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = ["input" "uinput" "networkmanager" "wheel" "docker" "i2c"];
  };

  # System-wide git
  programs.git = {
    enable = true;
    config = {
      user.name = "deredori";
      user.email = "deredori3@gmail.com";
      pull.rebase = false;
    };
  };
}
