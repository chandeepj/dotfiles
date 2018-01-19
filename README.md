# About
This repository contains everything needed to bootstrap and configure new Mac computer. It is opinionated and based on my own work flows. It is highly recommended that you fork this and customize it for your own purposes. Included here are:

* dotfiles
* ~/bin/ scripts
* Configuration files
* Scripting templates and utilities
* Bootstrap scripts to automate the process of provisioning a new computer or VM.

**Disclaimer:**  *I am not a professional or trained programmer and I bear no responsibility whatsoever if any of these scripts wipes your computer, destroys your data, burns your toast, crashes your car, or otherwise causes mayhem and destruction.  USE AT YOUR OWN RISK.*

The files are organized into three subdirectories.

```
dotfiles/
  ├── bin/
  ├── bootstrap/
  │   ├── config-macOS.yaml
  │   ├── install-macOS.sh
  │   └── config/
  │   └── lib/
  │      ├── mac-plugins/
  │      └── linux-plugins/
  ├── config/
  │   ├── bash/
  │   └── sync/
  ├── scripting/
```

* **bin/** - Symlinked to `~/bin` and is added to your `$PATH` allowing scripts to be executable by your user.
* **bootstrap/** - Scripts and utilities to bootstrap a new computer
* bootstrap/**config/** - Contains YAML files which are the manifest for the list of packages to be installed or symlinks to be created.
* bootstrap/lib/**mac-plugins** - Plugins that are run by `install-macOS.sh`
* bootstrap/lib/**linux-plugins** - Plugins that are run by `install-linux.sh`
* **config/** - Contains the elements needed to configure your environment and specific apps.
* config/**bash/** - Files in this directory are *sourced* by `.zshrc`.
* config/**sync/** - Files here are symlinked to your local environment. Ahem, dotfiles.
* **scripting/** - This directory contains bash scripting utilities and templates which I re-use often.

**IMPORTANT:** Unless you want to use my defaults, make sure you do the following:

* Edit all the config YAML files in `bootstrap/config/` to reflect your preferences
* Review the files in `config/` to configure your own aliases, preferences, etc.

### Private Files
Sometimes there are files which contain private information. These might be API keys, local directory structures, or anything else you want to keep hidden. I keep these in a separate private repository which has a folder structure very similar to this one. To configure your own private files edit the following files to reflect your setup

* Both bootstrap install scripts have a variable for the location of a private install script.  If that script is found, it will be run.
* Edit `config/sync/zshrc` to add the location of your private plugins

## Cloning this repo to a new computer
The first step needed to use these dotfiles is to clone this repo into the `$HOME` directory.

Now you're ready to run `~/dotfiles/bootstrap/*.sh` and get your new computer working.

## A Note on Code Reuse
Many of the scripts, configuration files, and other information herein were created by me over many years without ever having the intention to make them public. As a novice programmer, I have Googled, GitHubbed, and StackExchanged a path to solve my own scripting needs.  Quite often I lift a function whole-cloth from a GitHub repo don't keep track of it's original location. I have done my best within these files to recreate my footsteps and give credit to the original creators of the code when possible. Unfortunately, I fear that I missed as many as I found. My goal of making this repository public is not to take credit for the wonderful code written by others. If you recognize something that I didn't credit, please let me know.

Credits: Most of the files are shamelessly copied from `https://github.com/natelandau/dotfiles` :P