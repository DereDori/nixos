# Obsidian community plugins for ~/Documents/HeartsVault, declaratively
# installed instead of managed by hand through Obsidian's plugin browser.
#
# Each plugin ships its build as 3 separate GitHub release assets
# (manifest.json, main.js, styles.css), not a tarball, so each file is
# fetched on its own with pkgs.fetchurl.
#
# Deliberately NOT managed here -- left for Obsidian to read/write:
#   - .obsidian/community-plugins.json: already lists & enables all three.
#   - <plugin>/data.json: per-plugin runtime settings; remotely-save's
#     holds live sync credentials/state.
#
# To bump a plugin version: change `tag` and refetch the 3 sha256s with
# nix-prefetch-url <url> (no --unpack, these are plain files).
#
# force = true: these plugins were originally installed by hand, so
# home-manager would otherwise refuse to clobber the existing regular files.
{
  pkgs,
  lib,
  ...
}: let
  pluginsDir = "Documents/HeartsVault/.obsidian/plugins";

  fetchPluginFiles = {
    id,
    owner,
    repo,
    tag,
    manifestSha256,
    mainSha256,
    stylesSha256,
  }: let
    asset = file: sha256:
      pkgs.fetchurl {
        url = "https://github.com/${owner}/${repo}/releases/download/${tag}/${file}";
        inherit sha256;
      };
  in {
    "${pluginsDir}/${id}/manifest.json" = {
      source = asset "manifest.json" manifestSha256;
      force = true;
    };
    "${pluginsDir}/${id}/main.js" = {
      source = asset "main.js" mainSha256;
      force = true;
    };
    "${pluginsDir}/${id}/styles.css" = {
      source = asset "styles.css" stylesSha256;
      force = true;
    };
  };
in {
  home.file =
    fetchPluginFiles {
      id = "obsidian-full-calendar";
      owner = "davish";
      repo = "obsidian-full-calendar";
      tag = "0.10.7";
      manifestSha256 = "1wdh7bnj8ika87jlkdkxm3v3zmk6p3k221184qbfcwgz5r5y8wqi";
      mainSha256 = "1m8f66g8n4pbnkjxlz5d7byxfzgl6c00yib9vadg65ci6qsd4l3s";
      stylesSha256 = "04rsrhqnnv208skpyzyb0fhg449d6rdiahzranadd0fi0pq2slrk";
    }
    // fetchPluginFiles {
      id = "remotely-save";
      owner = "remotely-save";
      repo = "remotely-save";
      tag = "0.5.25";
      manifestSha256 = "145a9inbj0195nhk7sapaxak2nvf564amrw0d1lklgq02svc1nbi";
      mainSha256 = "017s24n3d6agfxrg1g0avhsa9fk9g1h5ij8q8rwbk22iy4kvvbxk";
      stylesSha256 = "1cyzw3lr5jikrry4ny5zwz52na7a15dn5cpvg998r9ccadylwn47";
    }
    // fetchPluginFiles {
      id = "obsidian-media-db-plugin";
      owner = "mProjectsCode";
      repo = "obsidian-media-db-plugin";
      tag = "0.9.1";
      manifestSha256 = "13riydm5p4jky79nn17gn2j83jhvva4fj0ki8adx9sglarphvzk2";
      mainSha256 = "1kqdmhnn39bwlshbbarx4hl9mkjzf6w3dvvbmgaij4h3zwrsc4cm";
      stylesSha256 = "0dyx43rcq8pl40kzpfpprysd6rk3srkmvf5idni6kgwpl6amkjkq";
    };
}
