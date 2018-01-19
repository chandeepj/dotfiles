#!/usr/bin/env bash

version="1.0.0"

_mainScript_() {

  if ! [[ "$OSTYPE" =~ "darwin"* ]]; then
    notice "Can only run on macOS.  Exiting."
    _safeExit_
  fi

  # Config files
  configVScode="${HOME}/dotfiles/bootstrap/config/homebrewCasks.yaml"

  _vscodePlugins_() {
    local vsplugin
    local testInstalled
    local t="${tmpDir}/${RANDOM}.${RANDOM}.${RANDOM}.txt"
    local c="$1" # Config YAML file

    info "Checking for vscode..."
    if ! [ -e /Applications/Visual\ Studio\ Code.app ]; then
        warning "Could not find Visual Studio Code.app. Please install Visual Studio Code and run this again."
        return
    else

    if ! _seekConfirmation_ "Install vscode plugins?"; then return; fi

      [ ! -f "$c" ] \
        && {
          error "Can not find config file '$c'"
          return 1
        }

      # Parse & source Config File
      # shellcheck disable=2015
      (_parseYAML_ "${c}" >"${t}") || 
        die "Could not parse YAML config file" "$LINENO" #\
        #&& { if $verbose; then
        #  verbose "-- Config Variables"
        #  _readFile_ "$t"
        #  fi; } \

      _sourceFile_ "$t"

      # Brew updates can take forever if we're not bootstrapping. Show the output
      saveVerbose=$verbose
      verbose=true

      header "Installing vscode Plugins"
      # shellcheck disable=2154
      for vsplugin in "${vscode[@]}"; do

        vsplugin=$(echo "${vsplugin}" | cut -d'#' -f1 | _trim_) # remove comments if exist
        installedPlugins=$(code --list-extensions)

        # strip flags from package names
        testInstalled=$(echo "${vsplugin}" | cut -d' ' -f1 | _trim_)
        if _list_contains_item_ "$installedPlugins" "${testInstalled}" ; then
          info "${testInstalled} already installed"
        else
         _execute_ "code --install-extension $vsplugin" "Install ${vsplugin}"
        fi
      done

      verbose=$saveVerbose     # Reset verbose settings
    fi
  }
  _vscodePlugins_ "$configVScode"

} # end _mainScript_

_sourceHelperFiles_() {
  local filesToSource
  local sourceFile
  filesToSource=(
    "${HOME}/dotfiles/scripting/helpers/baseHelpers.bash"
    "${HOME}/dotfiles/scripting/helpers/arrays.bash"
    "${HOME}/dotfiles/scripting/helpers/files.bash"
    "${HOME}/dotfiles/scripting/helpers/textProcessing.bash"
  )
  for sourceFile in "${filesToSource[@]}"; do
    [ ! -f "$sourceFile" ] \
      && {
        echo "error: Can not find sourcefile '$sourceFile'."
        echo "exiting..."
        exit 1
      }
    source "$sourceFile"
  done
}
_sourceHelperFiles_

# Set Base Variables
# ----------------------
scriptName=$(basename "$0")

# Set Flags
quiet=false
printLog=false
logErrors=true
verbose=false
force=false
strict=false
dryrun=false
debug=false
sourceOnly=false
args=()

# Set Temp Directory
tmpDir="/tmp/${scriptName}.$RANDOM.$RANDOM.$RANDOM.$$"
(umask 077 && mkdir "${tmpDir}") || {
  die "Could not create temporary directory! Exiting."
}

# Options and Usage
# -----------------------------------
_usage_() {
  echo -n "${scriptName} [OPTION]...

This script installs plugin extensions for visual studio code.


 ${bold}Option Flags:${reset}

  --rootDIR         The location of the 'dotfiles' directory
  -L, --noErrorLog  Print log level error and fatal to a log (default 'true')
  -l, --log         Print log to file
  -n, --dryrun      Non-destructive. Makes no permanent changes.
  -q, --quiet       Quiet (no output)
  -s, --strict      Exit script with null variables.  i.e 'set -o nounset'
  -v, --verbose     Output more information. (Items echoed to 'verbose')
  -d, --debug       Runs script in BASH debug mode (set -x)
  -h, --help        Display this help and exit
      --version     Output version information and exit
      --source-only Bypasses main script functionality to allow unit tests of functions
      --force       Skip all user interaction.  Implied 'Yes' to all actions.
"
}

# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
optstring=h
unset options
while (($#)); do
  case $1 in
    # If option is of type -ab
    -[!-]?*)
      # Loop over each character starting with the second
      for ((i = 1; i < ${#1}; i++)); do
        c=${1:i:1}

        # Add current char to options
        options+=("-$c")

        # If option takes a required argument, and it's not the last char make
        # the rest of the string its argument
        if [[ $optstring == *"$c:"* && ${1:i+1} ]]; then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;

    # If option is of type --foo=bar
    --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
    # add --endopts for --
    --) options+=(--endopts) ;;
    # Otherwise, nothing special
    *) options+=("$1") ;;
  esac
  shift
done
set -- "${options[@]}"
unset options

# Print help if no arguments were passed.
# Uncomment to force arguments when invoking the script
# -------------------------------------
# [[ $# -eq 0 ]] && set -- "--help"

# Read the options and set stuff
while [[ $1 == -?* ]]; do
  case $1 in
    --rootDIR)
      shift
      baseDir="$1"
      ;;
    -h | --help)
      _usage_ >&2
      _safeExit_
      ;;
    -L | --noErrorLog) logErrors=false ;;
    -n | --dryrun) dryrun=true ;;
    -v | --verbose) verbose=true ;;
    -l | --log) printLog=true ;;
    -q | --quiet) quiet=true ;;
    -s | --strict) strict=true ;;
    -d | --debug) debug=true ;;
    --version)
      echo "$(basename $0) ${version}"
      _safeExit_
      ;;
    --source-only) sourceOnly=true ;;
    --force) force=true ;;
    --endopts)
      shift
      break
      ;;
    *) die "invalid option: '$1'." ;;
  esac
  shift
done

# Store the remaining part as arguments.
args+=("$@")

# Trap bad exits with your cleanup function
trap '_trapCleanup_ $LINENO $BASH_LINENO "$BASH_COMMAND" "${FUNCNAME[*]}" "$0" "${BASH_SOURCE[0]}"' \
  EXIT INT TERM SIGINT SIGQUIT ERR

# Set IFS to preferred implementation
IFS=$' \n\t'

# Exit on error. Append '||true' when you run the script if you expect an error.
# set -o errexit
# set -o errtrace

# Force pipelines to fail on the first non-zero status code.
set -o pipefail

# Run in debug mode, if set
if ${debug}; then set -x; fi

# Exit on empty variable
if ${strict}; then set -o nounset; fi

# Run your script unless in 'source-only' mode
if ! ${sourceOnly}; then _mainScript_; fi

# Exit cleanly
if ! ${sourceOnly}; then _safeExit_; fi