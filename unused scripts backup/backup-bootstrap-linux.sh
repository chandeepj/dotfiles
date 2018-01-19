#!/usr/bin/env bash

version="1.0.0"

_mainScript_() {

  if ! [[ "$OSTYPE" =~ linux-gnu* ]]; then
    die "We are not on Linux"
  fi

  # Get privs upfront
  sudo -v

  # Set Variables
  baseDir="$(_findBaseDir_)"
  rootDIR="$(dirname "$baseDir")"

  _apgradeAptGet_() {
    # Upgrade apt-get
    if [ -f "/etc/apt/sources.list" ]; then
      notice "Upgrading apt-get....(May take a while)"
      apt-get update
      apt-get upgrade -y
    else
      die "Can not proceed without apt-get"
    fi

    apt-get install -y git
    apt-get install -y mosh
    apt-get install -y sudo
    apt-get install -y ncurses
    apt-get install -y software-properties-common
    apt-get install -y python3-software-properties
    apt-get install -y python-software-properties

  }
  _apgradeAptGet_

  _setHostname_() {
    notice "Setting Hostname..."

    ipAddress=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')

    input "What is your hostname? [ENTER]: "
    read -r newHostname

    [ ! -n "$newHostname" ] && die "Hostname undefined"

    if command -v hostnamectl &>/dev/null; then
      _execute_ "hostnamectl set-hostname \"$newHostname\""
    else
      _execute_ "echo \"$newHostname\" > /etc/hostname"
      _execute_ "hostname -F /etc/hostname"
    fi

    _execute_ "echo \"$ipAddress\" \"$newHostname\" >> /etc/hosts"
  }
  _setHostname_

  _setTime_() {
    notice "Setting Time..."

    if command -v timedatectl &>/dev/null; then
      _execute_ "apt-get install -y ntp"
      _execute_ "timedatectl set-timezone \"America/New_York\""
      _execute_ "timedatectl set-ntp true"
    elif command -v dpkg-reconfigure; then
      dpkg-reconfigure tzdata
    else
      die "set time failed"
    fi
  }
  _setTime_

  _addUser_() {

    # Installs sudo if needed and creates a user in the sudo group.
    notice "Creating a new user account..."
    input "username? [ENTER]: "
    read -r USERNAME
    input "password? [ENTER]: "
    read -r -s USERPASS

    _execute_ "adduser ${USERNAME} --disabled-password --gecos \"\""
    _execute_ "echo \"${USERNAME}:${USERPASS}\" | chpasswd" "echo \"${USERNAME}:******\" | chpasswd"
    _execute_ "usermod -aG sudo ${USERNAME}"

    HOMEDIR="/home/${USERNAME}"
  }
  _addUser_

  _addPublicKey_() {
    # Adds the users public key to authorized_keys for the specified user. Make sure you wrap your input variables in double quotes, or the key may not load properly.

    if _seekConfirmation_ "Do you have a public key from another computer to add?"; then
      if [ ! -n "$USERNAME" ]; then
        die "We must have a user account configured..."
      fi

      input "paste your public key? [ENTER]: "
      read -r USERPUBKEY

      _execute_ "mkdir -p /home/${USERNAME}/.ssh"
      _execute_ "echo \"$USERPUBKEY\" >> /home/${USERNAME}/.ssh/authorized_keys"
      _execute_ "chown -R \"${USERNAME}\":\"${USERNAME}\" /home/${USERNAME}/.ssh"
    fi
  }
  _addPublicKey_

  _installDotfiles_() {

    if command -v git &>/dev/null; then
      header "Installing dotfiles..."
      pushd "$HOMEDIR"
      git clone https://github.com/natelandau/dotfiles "${HOMEDIR}/dotfiles"
      chown -R $USERNAME:$USERNAME "${HOMEDIR}/dotfiles"
      popd
    else
      warning "Could not install dotfiles repo without git installed"
    fi
  }
  _installDotfiles_

  _ufwFirewall_() {
    header "Installing firewall with UFW"
    apt-get install -y ufw

    _execute_ "ufw default deny"
    _execute_ "ufw allow 'Nginx Full'"
    _execute_ "ufw allow ssh"
    _execute_ "ufw allow mosh"
    _execute_ "ufw enable"
  }
  _ufwFirewall_

  success "New computer bootstrapped."
  info "To continue you must log out as root and back in as the user you just"
  info "created. Once logged in you should see a 'dotfiles' folder in your user's home directory."
  info "Run the '~/dotfiles/bootstrap/install-linux-gnu.sh' script to continue"

  _disableRootSSH_() {
    notice "Disabling root access..."
    _execute_ "sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config"
    _execute_ "touch /tmp/restart-ssh"
    _execute_ "service ssh restart"
  }
  _disableRootSSH_

} # end _mainScript_

_execute_() {
  # v1.0.1
  # _execute_ - wrap an external command in '_execute_' to push native output to /dev/null
  #           and have control over the display of the results.  In "dryrun" mode these
  #           commands are not executed at all. In Verbose mode, the commands are executed
  #           with results printed to stderr and stdin
  #
  # usage:
  #   _execute_ "cp -R \"~/dir/somefile.txt\" \"someNewFile.txt\"" "Optional message to print to user"
  local cmd="${1:?_execute_ needs a command}"
  local message="${2:-$1}"
  if ${dryrun}; then
    dryrun "${message}"
  else
    if $verbose; then
      eval "$cmd"
    else
      eval "$cmd" &>/dev/null
    fi
    if [ $? -eq 0 ]; then
      success "${message}"
    else
      #error "${message}"
      die "${message}"
    fi
  fi
}

_seekConfirmation_() {
  # v1.0.1
  # Seeks a Yes or No answer to a question.  Usage:
  #   if _seekConfirmation_ "Answer this question"; then
  #     something
  #   fi

  input "$@"
  if "${force}"; then
    verbose "Forcing confirmation with '--force' flag set"
    echo -e ""
    return 0
  else
    while true; do
      read -r -p " (y/n) " yn
      case $yn in
        [Yy]*) return 0 ;;
        [Nn]*) return 1 ;;
        *) input "Please answer yes or no." ;;
      esac
    done
  fi
}

# Set Base Variables
# ----------------------
scriptName=$(basename "$0")

# Set Flags
quiet=false
printLog=false
verbose=false
force=false
strict=false
dryrun=false
debug=false
sourceOnly=false
args=()

# Set Colors
bold=$(tput bold)
reset=$(tput sgr0)
purple=$(tput setaf 171)
red=$(tput setaf 1)
green=$(tput setaf 76)
tan=$(tput setaf 3)
blue=$(tput setaf 38)
underline=$(tput sgr 0 1)

# Logging & Feedback
logFile="${HOME}/Library/Logs/${scriptName%.sh}.log"

_alert_() {
  # v1.0.0
  if [ "${1}" = "error" ]; then local color="${bold}${red}"; fi
  if [ "${1}" = "warning" ]; then local color="${red}"; fi
  if [ "${1}" = "success" ]; then local color="${green}"; fi
  if [ "${1}" = "debug" ]; then local color="${purple}"; fi
  if [ "${1}" = "header" ]; then local color="${bold}${tan}"; fi
  if [ "${1}" = "input" ]; then local color="${bold}"; fi
  if [ "${1}" = "dryrun" ]; then local color="${blue}"; fi
  if [ "${1}" = "info" ] || [ "${1}" = "notice" ]; then local color=""; fi
  # Don't use colors on pipes or non-recognized terminals
  if [[ "${TERM}" != "xterm"* ]] || [ -t 1 ]; then
    color=""
    reset=""
  fi

  # Print to console when script is not 'quiet'
  if ${quiet}; then
    tput cuu1
    return
  else # tput cuu1 moves cursor up one line
    echo -e "$(date +"%r") ${color}$(printf "[%7s]" "${1}") ${_message}${reset}"
  fi

  # Print to Logfile
  if ${printLog} && [ "${1}" != "input" ]; then
    color=""
    reset="" # Don't use colors in logs
    echo -e "$(date +"%m-%d-%Y %r") $(printf "[%7s]" "${1}") ${_message}" >>"${logFile}"
  fi
}

function die() {
  local _message="${*} Exiting."
  echo -e "$(_alert_ error)"
  _safeExit_ "1"
}
function error() {
  local _message="${*}"
  echo -e "$(_alert_ error)"
}
function warning() {
  local _message="${*}"
  echo -e "$(_alert_ warning)"
}
function notice() {
  local _message="${*}"
  echo -e "$(_alert_ notice)"
}
function info() {
  local _message="${*}"
  echo -e "$(_alert_ info)"
}
function debug() {
  local _message="${*}"
  echo -e "$(_alert_ debug)"
}
function success() {
  local _message="${*}"
  echo -e "$(_alert_ success)"
}
function dryrun() {
  local _message="${*}"
  echo -e "$(_alert_ dryrun)"
}
function input() {
  local _message="${*}"
  echo -n "$(_alert_ input)"
}
function header() {
  local _message="== ${*} ==  "
  echo -e "$(_alert_ header)"
}
function verbose() { if ${verbose}; then debug "$@"; fi; }

# Options and Usage
# -----------------------------------
_usage_() {
  echo -n "${scriptName} [OPTION]... [FILE]...

This script runs a series of installation scripts to bootstrap a new computer or VM running Debian GNU linux

 ${bold}Options:${reset}

  -n, --dryrun      Non-destructive. Makes no permanent changes.
  -q, --quiet       Quiet (no output)
  -l, --log         Print log to file
  -s, --strict      Exit script with null variables.  i.e 'set -o nounset'
  -v, --verbose     Output more information. (Items echoed to 'verbose')
  -d, --debug       Runs script in BASH debug mode (set -x)
  -h, --help        Display this help and exit
      --source-only Bypasses main script functionality to allow unit tests of functions
      --version     Output version information and exit
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
    -h | --help)
      _usage_ >&2
      _safeExit_
      ;;
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
trap _trapCleanup_ EXIT INT TERM

# Set IFS to preferred implementation
IFS=$' \n\t'

# Exit on error. Append '||true' when you run the script if you expect an error.
# if using the 'execute' function this must be disabled for warnings to be shown if tasks fail
#set -o errexit

# Force pipelines to fail on the first non-zero status code.
set -o pipefail

# Run in debug mode, if set
if ${debug}; then set -x; fi

# Exit on empty variable
if ${strict}; then set -o nounset; fi

# Exit the script if a command fails
#set -e

# Run your script unless in 'source-only' mode
if ! ${sourceOnly}; then _mainScript_; fi

# Exit cleanly
if ! ${sourceOnly}; then _safeExit_; fi
