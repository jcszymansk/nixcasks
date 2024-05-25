# Brew Casks, nixified

This project is an effort to enable installing applications from Homebrew Casks repository as first
class Nix packages, and therefore to make it possible to manage them with the usual Nix tools,
especially Home Manager but also Nix-darwin and possibly others.

For most cases it should already work (but see limitations), I've been using it to manage most of the
Homebrew Cask apps I use from the very first day I started this.

### How to use:

#### with flakes:

- add this repository to your flake inputs, e.g.
```nix
    nixcasks = {
      url = "github:jacekszymanski/nixcasks";
      inputs.nixpkgs.follows = "nixpkgs";
    };
```

- in outputs add (you must have `${system}` already available)
```nix
    nixcasks = (inputs.nixcasks.output {
       osVersion = "monterey";
    }).packages.${system};
```
- add `nixcasks` to your pkgs, the recomended way is via `packageOverrides`:

```nix
    pkgs = import nixpkgs {
      inherit system;
      config.packageOverrides = _: {
        inherit nixcasks;
      };
    };
```

- now `nixcasks` is available under `pkgs`, e.g. `pkgs.nixcasks.vlc`

#### without flakes (not recommended):

- import this repository in your nix file, you may clone it and import from your filesystem or import directly from github:
```nix
    nixcasks = import (fetchTarball "https://github.com/jacekszymanski/nixcasks/archive/master.tar.gz") {
      inherit pkgs;
      osVersion = "sonoma";
    }
```
- use packages from `nixcasks`, e.g. `nixcasks.vlc`


### Application variants

By default Nixcasks selects an application variant for your architecture (as determined from `pkgs.system`) and for the oldest yet supported macOS version, which is now `monterey`. If you want to use variants for a newer version of macOS, you need to declare it in the attribute `osVersion` in your import.

**NOTE**: as I don't have an ARM mac, ARM variations are now not tested at all; feel free to test and
open an issue in case of problems.

### What is supported

Most simple applications which have no installer are already supported; ```casks.json``` contains 2874
entries as I write it.

The applications' list is updated from Homebrew daily by a github action, so ```nixcasks``` has almost
no delay behind the Homebrew.

Overrides: this allows specifying app-specific attributes which are not included in `casks.json`

Applications which require renaming (`target` attribute)

### What is not yet supported

- `binary` artifacts
- custom taps
- local app definitions

### What will (probably) never be supported

- Applications with .pkg's and/or installers
- Applications which require and/or install system extensions (they might be added by the automated job,
  but expect problems with updates etc.)

### Limitations

Home Manager and Nix-Darwin symlink the entries from Nix store into their respective Applications directories,
the applications do not expect this and thus register their actual path (not the symlink) in the system
registries, which **will** lead to confused effects, such as older instance being still available and associated
with files open action despite an update. A possible workaround is [here](https://github.com/YorikSar/dotfiles/commit/d7eccf447a399c15fe987ab02db13f4ef1e1b557), also see this [discussion](https://github.com/nix-community/home-manager/issues/1341#issuecomment-1653434732).

Some DMG images (e.g. docker) use the new ULMO format and I am not aware of any way to unpack them in pure mode
(required by sandbox). For now, and until the next `7zip` release a workaround is used, an image which fails to
test with `7zip` is converted to an older format and then unpacked. The conversion requires `hdiutil` though,
which breaks pure mode and therefore sandbox (see this [issue](https://github.com/jacekszymanski/nixcasks/issues/2)).

# LICENSE

This project is MIT-licensed. This is applicable to the Nix expressions, shell scripts and other
software written for this project only. This license does not apply to any package which may be
managed with the help of this project.

# WARNING

There are many commercial packages in Homebrew Casks; neither this project nor Homebrew does distribute or
sell them; it's **your (the user's) responsibility** to properly obtain any required license. Both Homebrew
and this project only provide a way to automate their (un)installation.
