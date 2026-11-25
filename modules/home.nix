# home-manager wired in as a NixOS module (single rebuild manages both).
{username, ...}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit username;};

    users.${username} = let
      # Matt Pocock's Claude Code skills (github:mattpocock/skills), pinned.
      # To pick up new/updated skills: bump the commit in the url and refetch
      # the hash with `nix-prefetch-url --unpack <url>`.
      mpSkills = builtins.fetchTarball {
        url = "https://github.com/mattpocock/skills/archive/d65391149dbb5fe76478e76fa8d5122b2aa5a70e.tar.gz";
        sha256 = "024pfnbw1cdyh8pf54hcynxgbb3lizc2ck172xvkmirshp57szwj";
      };
    in {
      home.stateVersion = "26.05";

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      # Dotfiles. Paths are relative to THIS file (modules/), hence ../dotfiles.
      home.file = {
        ".config/tmux/tmux.conf".source = ../dotfiles/tmux.conf;
        ".config/ghostty/config".source = ../dotfiles/ghostty;
        ".bashrc".source = ../dotfiles/bashrc;
        ".bash_profile".source = ../dotfiles/bash_profile;
        ".config/gdb/gdbinit".source = ../dotfiles/gdbinit;
        ".config/nvim" = {
          source = ../dotfiles/nvim;
          recursive = true;
        };

        # Selected Claude Code skills from mattpocock/skills.
        ".claude/skills/grill-with-docs".source = "${mpSkills}/skills/engineering/grill-with-docs";
        ".claude/skills/to-spec".source = "${mpSkills}/skills/engineering/to-spec";
        ".claude/skills/implement-spec".source = "${mpSkills}/skills/engineering/implement-spec";
        ".claude/skills/pr".source = "${mpSkills}/skills/engineering/pr";
        ".claude/skills/retro".source = "${mpSkills}/skills/engineering/retro";
        ".claude/skills/improve-codebase-architecture".source = "${mpSkills}/skills/engineering/improve-codebase-architecture";
        ".claude/skills/teach".source = "${mpSkills}/skills/productivity/teach";
      };

      # direnv + nix-direnv: entering a project folder with an .envrc
      # (`use flake`) auto-loads its devshell. The shell hook itself is added
      # in dotfiles/bashrc (since .bashrc is a managed static file).
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      # Open files/folders with nvim instead of yazi's nano fallback.
      programs.yazi = {
        enable = true;
        settings = {
          opener = {
            edit = [
              {run = ''nvim "$@"''; block = true; for = "unix";}
            ];
          };
          open.rules = [
            {name = "*/"; use = "edit";}
            {mime = "text/*"; use = "edit";}
            {mime = "application/json"; use = "edit";}
            {mime = "application/x-shellscript"; use = "edit";}
          ];
        };
      };
    };
  };
}
