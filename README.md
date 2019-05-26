# About
This repository contains everything needed to bootstrap and configure new Mac computer. It is opinionated and based on my own work flows. It is highly recommended that you fork this and customize it for your own purposes. Included here are:

* dotfiles
* ~/bin/ scripts
* Configuration files
* Scripting templates and utilities
* Bootstrap scripts to automate the process of provisioning a new computer or VM.

**Disclaimer:**  *I bear no responsibility whatsoever if any of these scripts wipes your computer and destroys your data.  USE AT YOUR OWN RISK.*

The files are organized into three subdirectories.

```
dotfiles/
  ├── bin/
  ├── bootstrap/
  │   ├── config-linux.sh
  │   ├── config-macOS.sh
  │   └── config/
  │   └── plugins/
  ├── config/
  │   ├── iTerm/
  │   └── sync/
  ├── scripting/
```

* **bin/** - Symlinked to `~/bin` and is added to your `$PATH` allowing scripts to be executable by your user.
* **bootstrap/** - Scripts and utilities to bootstrap a new computer
* bootstrap/**config/** - Contains YAML files which are the manifest for the list of packages to be installed or symlinks to be created.
* bootstrap/lib/**plugins** - Contains plugins that are run by `~/dotfiles/bootstrap/config-*.sh`
* **config/** - Contains the elements needed to configure your environment and specific apps.
* config/**iTerm/** - Contains iTerm2 config files, Theme and fonts.
* config/**sync/** - Files here are symlinked to your local environment.
* **scripting/** - This directory contains bash scripting utilities and templates which can be re-used.

**IMPORTANT:** Unless you want to use my defaults, make sure you do the following:

* Edit all the config YAML files in `bootstrap/config/` to reflect your preferences
* Review the files in `config/` to configure your own aliases, preferences, etc.

## Cloning this repo to a new computer
The first step needed to use these dotfiles is to clone this repo into the `$HOME` directory.

Now you're ready to run `~/dotfiles/bootstrap/config-*.sh` and get your new computer working.

## Credits
* **[natelandau](https://github.com/natelandau/dotfiles)** - Used it as a base and tweaked to my needs.