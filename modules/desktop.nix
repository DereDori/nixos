# GNOME desktop, display server, audio, printing, and dconf settings.
{pkgs, ...}: {
  # X / GNOME
  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # Keyboard layout (X11)
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Printing
  services.printing.enable = true;

  # External-monitor brightness over DDC/CI.
  # hardware.i2c.enable loads the i2c-dev module, installs udev rules, and
  # creates the `i2c` group (fbruggem is added to it in system.nix). ddcutil
  # is the backend; the GNOME extension adds a brightness slider per external
  # monitor in the quick-settings panel (the internal panel keeps its own).
  hardware.i2c.enable = true;
  environment.systemPackages = with pkgs; [
    ddcutil
    gnomeExtensions.brightness-control-using-ddcutil
  ];

  # Audio via PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # GNOME settings via dconf.
  # Discover keys with:
  #   gsettings list-schemas
  #   gsettings list-keys SCHEMA_NAME
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = {
          "org/gnome/shell" = {
            enabled-extensions = [
              pkgs.gnomeExtensions.brightness-control-using-ddcutil.extensionUuid
            ];
            favorite-apps = pkgs.lib.gvariant.mkEmptyArray pkgs.lib.gvariant.type.string;
          };
          "org/gnome/shell/keybindings" = {
            "show-screenshot-ui" = ["<Super>s"];
            # Free up Super+1..9 (GNOME uses them to launch dash apps by default)
            "switch-to-application-1" = pkgs.lib.gvariant.mkEmptyArray pkgs.lib.gvariant.type.string;
            "switch-to-application-2" = pkgs.lib.gvariant.mkEmptyArray pkgs.lib.gvariant.type.string;
            "switch-to-application-3" = pkgs.lib.gvariant.mkEmptyArray pkgs.lib.gvariant.type.string;
            "switch-to-application-4" = pkgs.lib.gvariant.mkEmptyArray pkgs.lib.gvariant.type.string;
            "switch-to-application-5" = pkgs.lib.gvariant.mkEmptyArray pkgs.lib.gvariant.type.string;
            "switch-to-application-6" = pkgs.lib.gvariant.mkEmptyArray pkgs.lib.gvariant.type.string;
            "switch-to-application-7" = pkgs.lib.gvariant.mkEmptyArray pkgs.lib.gvariant.type.string;
            "switch-to-application-8" = pkgs.lib.gvariant.mkEmptyArray pkgs.lib.gvariant.type.string;
            "switch-to-application-9" = pkgs.lib.gvariant.mkEmptyArray pkgs.lib.gvariant.type.string;
          };
          "org/gnome/desktop/background" = {
            "picture-uri" = "file://${../dotfiles/wallpaper.jpg}";
            "picture-uri-dark" = "file://${../dotfiles/wallpaper.jpg}";
            "picture-options" = "zoom";
          };
          "org/gnome/desktop/screensaver" = {
            "picture-uri" = "file://${../dotfiles/wallpaper.jpg}";
          };
          "org/gnome/desktop/wm/keybindings" = {
            "switch-to-workspace-1" = ["<Super>1"];
            "switch-to-workspace-2" = ["<Super>2"];
            "switch-to-workspace-3" = ["<Super>3"];
            "switch-to-workspace-4" = ["<Super>4"];
            "switch-to-workspace-5" = ["<Super>5"];
            "toggle-fullscreen" = ["<Super>f"];
            "close" = ["<Super>q"];
          };
          "org/gnome/desktop/wm/preferences" = {
            "num-workspaces" = pkgs.lib.gvariant.mkInt32 5;
          };
          "org/gnome/mutter" = {
            "dynamic-workspaces" = false;
          };
          "org/gnome/settings-daemon/plugins/media-keys" = {
            "search" = ["<Control>space"];
            "custom-keybindings" = [
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
            ];
          };
          # Super+W -> Zen browser
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            name = "Zen Browser";
            command = "flatpak run app.zen_browser.zen";
            binding = "<Super>w";
          };
          # Super+T -> Ghostty
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
            name = "Ghostty";
            command = "ghostty";
            binding = "<Super>t";
          };
          # Super+R -> Obsidian
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
            name = "Obsidian";
            command = "flatpak run md.obsidian.Obsidian";
            binding = "<Super>r";
          };
          # Super+Y -> Discord
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
            name = "Discord";
            command = "flatpak run com.discordapp.Discord";
            binding = "<Super>y";
          };
          # Super+E -> Ghostty running yazi as root
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
            name = "Yazi";
            command = "ghostty -e yazi";
            binding = "<Super>e";
          };
          "org/gnome/desktop/input-sources" = {
            "xkb-options" = ["caps:escape"];
          };
          # merged: this block was defined twice before
          "org/gnome/desktop/interface" = {
            "enable-hot-corners" = false;
            enable-animations = false;
            "color-scheme" = "prefer-dark";
            "gtk-theme" = "Adwaita-dark";
            scaling-factor = pkgs.lib.gvariant.mkUint32 1;
            text-scaling-factor = 1.0;
          };
          "org/gnome/desktop/peripherals/mouse" = {
            natural-scroll = false;
          };
          "org/gnome/desktop/peripherals/touchpad" = {
            natural-scroll = false;
          };
        };
        lockAll = true; # enforce the settings strictly
      }
    ];
  };
}
