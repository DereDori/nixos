# System packages, unfree allowance, and nix-ld (so LazyVim/Mason binaries run).
{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  # nix-ld provides a standard dynamic linker so prebuilt binaries (e.g. the
  # tools Mason downloads for Neovim) run on NixOS. This is what makes the
  # LazyVim setup "just work" here.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
    ];
  };

  programs.steam.enable = true;
  services.tailscale.enable = true;
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = ["thefool"];

  environment.systemPackages = with pkgs; [
    # Apps
    ghostty
    tmux
    git
    qbittorrent

    # Editor + CLI
    neovim
    fzf
    ripgrep
    xclip
    tree-sitter
    nodejs
    nil # nix language server
    busybox
    yazi
    libreoffice-fresh
    fd
    zoxide

    # C / systems programming
    man-pages
    clang
    clang-tools # clangd
    cargo
    gdb

    bundletool

    # Entertainment
    cava
    reaper
    krita
    (ani-cli.overrideAttrs (old: {
        version = "master-a9d789f";
        src = fetchFromGitHub {
          owner = "pystardust";
          repo = "ani-cli";
          rev = "a9d789ffeabcecb3d0fe0e118ee20ec7cd33c398";
          hash = "sha256-5oEI4qUG0SlKmuRDezt3zLdSsHoMpjhtAacXHREIzpA=";
        };
    }))
  ];
}
