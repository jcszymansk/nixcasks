# Brew Casks, nixified

This is a WIP to support declarative installation of Homebrew Casks on macOS, now just a start, but
for apps which are installed by copying .app bundle to /Applications it should work.

Now it only supports casks that have no pkg/installer and only one "app" artifact.

Applications that start at login are **unsupported** (they'll install, but they'll start the first
installed version every time; it should be easy to fix as a Home Manager module...)

Variants are unsupported.

# WARNING

There are many commercial packages in Homebrew Casks; neither this project nor Homebrew does distribute or
sell them; it's **your (the user's) responsibility** to properly obtain any required license. Both Homebrew
and this project only provide a way to automate their (un)installation.

### How to use:

- add this to your flake inputs
- in outputs add ```nixcasks = inputs.nixcasks.legacyPackages."${system}"``` to your pkgs
- in your config use packages like ```with pkgs.nixcasks [ mpv paintbrush tor-browser]``` and so on

## TODO

- github action to update casks.json...
- support more casks, installers and if possible .pkg's
- support adding services/autologins
- better docs
- support brews?

Pull requests welcome :-)

# LICENSE

This project is MIT-licensed. This is applicable to the Nix expressions, shell scripts and other
software written for this project only. This license does not apply to any package which may be
managed with the help of this project.
