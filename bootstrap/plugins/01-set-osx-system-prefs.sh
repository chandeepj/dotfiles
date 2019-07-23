#!/usr/bin/env bash

version="1.0.0"

_mainScript_() {

  if [[ ! "$OSTYPE" == "darwin"* ]]; then
    warning "$scriptName can only run on macOS. Exiting."
    _safeExit_
  else
    header "Configuring  Mac OS System Preferences..."

    # Ask for sudo privs up-front
    sudo -v

    # Set Computer Name
    if _seekConfirmation_ "Would you like to set your computer name (as done via System Preferences >> Sharing)?"; then
      input "What would you like the name to be? "
      read -r COMPUTER_NAME
      _execute_ "sudo scutil --set ComputerName $COMPUTER_NAME"
      _execute_ "sudo scutil --set HostName $COMPUTER_NAME"
      _execute_ "sudo scutil --set LocalHostName $COMPUTER_NAME"
      _execute_ "sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $COMPUTER_NAME"
    fi

    # General UI Tweaks
    # ---------------------------
    _execute_ "sudo nvram SystemAudioVolume=%80' '" "Disable Sound Effects on Boot"

    _execute_ "defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2" "Set sidebar icon size to medium"
    # Possible values for int: 1=small, 2=medium

    _execute_ "defaults write NSGlobalDomain AppleShowScrollBars -string 'WhenScrolling'" "Show scrollbars WhenScrolling"
    # Possible values: `WhenScrolling`, `Automatic` and `Always`

    #_execute_ "defaults write com.apple.universalaccess reduceTransparency -bool true" "Disable transparency in the menu bar and elsewhere"

    _execute_ "defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false" "Disable opening and closing window animations"

    _execute_ "defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true" "Expand save panel by default"
    _execute_ "defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true" "Expand save panel by default"

    _execute_ "defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true" "Expand print panel by default"
    _execute_ "defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true" "Expand print panel by default"

    #_execute_ "defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false" "Save to disk (not to iCloud) by default"

    _execute_ "defaults write com.apple.print.PrintingPrefs 'Quit When Finished' -bool true" "Automatically quit printer app once the print jobs complete"

    #_execute_ "defaults write com.apple.LaunchServices LSQuarantine -bool false" "Disable the 'Are you sure you want to open this application?' dialog"

    # Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
    _execute_ "defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true" "General:Display ASCII control characters using caret notation in standard text views"

    _execute_ "defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true" "Disable automatic termination of inactive apps"

    _execute_ "defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false" "Disable Resume system-wide"

    _execute_ "sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName" "Reveal info when clicking the clock in the login window"

    #_execute_ "systemsetup -setrestartfreeze on" "Restart automatically if the computer freezes"

    #_execute_ "systemsetup -setcomputersleep Off > /dev/null" "Never go into computer sleep mode"

    _execute_ "defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1" "Check for software updates daily, not just once per week"

    #_execute_ "launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null" "Disable Notification Center and remove the menu bar icon"

    _execute_ "defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false" "Disable smart quotes as they are annoying when typing code"

    _execute_ "defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false" "Disable smart dashes as they are annoying when typing code"

    _execute_ "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user" "Removing duplicates in the 'Open With' menu"

    #_execute_ "sudo pmset -a hibernatemode 0" "Disable hibernation? (speeds up entering sleep mode)"

    # Input Device Preferences
    # ---------------------------

    success "Trackpad: enable tap to click for this user and for the login screen"
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    success "Trackpad: map bottom right corner to right-click"
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

    # success "Disable “natural” (Lion-style) scrolling"
    # defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

    _execute_ "defaults write -g com.apple.trackpad.scaling 2" "Setting trackpad & mouse speed to a reasonable number"
    _execute_ "defaults write -g com.apple.mouse.scaling 2.5" "Setting trackpad & mouse speed to a reasonable number"

    _execute_ "defaults write com.apple.BluetoothAudioAgent 'Apple Bitpool Min (editable)' -int 40" "Increase sound quality for Bluetooth headphones/headsets"

    _execute_ "defaults write NSGlobalDomain AppleKeyboardUIMode -int 3" "Enable full keyboard access for all controls"

    _execute_ "defaults write com.apple.BezelServices kDim -bool true" "Automatically illuminate built-in MacBook keyboard in low light"

    _execute_ "defaults write com.apple.BezelServices kDimTime -int 300" "Turn off keyboard illumination when computer is not used for 5 minutes"

    success "Set language and text formats"
    # Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
    # `Inches`, `en_GB` with `en_US`, and `true` with `false`.
    defaults write NSGlobalDomain AppleLanguages -array "en" "nl"
    defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
    defaults write NSGlobalDomain AppleMeasurementUnits -string "Inches"
    defaults write NSGlobalDomain AppleMetricUnits -bool false

    success "Set the timezone to Asia/Calcutta"
    systemsetup -settimezone "Asia/Calcutta" >/dev/null
    #see `systemsetup -listtimezones` for other values

    success "Disable spelling auto-correct"
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    # Stop iTunes from responding to the keyboard media keys
    #launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

    # Screen Preferences
    # ---------------------------

    _execute_ "defaults write com.apple.screensaver askForPassword -int 1" "Require password immediately after sleep or screen saver begins"
    _execute_ "defaults write com.apple.screensaver askForPasswordDelay -int 0" "Require password immediately after sleep or screen saver begins"

    _execute_ "defaults write com.apple.screencapture location -string ${HOME}/Desktop" "Save screenshots to the desktop"

    _execute_ "defaults write com.apple.screencapture type -string 'png'" "Save screenshots in PNG format"
    # other options: BMP, GIF, JPG, PDF, TIFF, PNG

    _execute_ "defaults write com.apple.screencapture disable-shadow -bool true" "Disable shadow in screenshots"

    _execute_ "defaults write NSGlobalDomain AppleFontSmoothing -int 2" "Enable subpixel font rendering on non-Apple LCDs"

    _execute_ "sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true" "Enabling HiDPI display modes (requires restart)"

    # Screen Preferences
    # ---------------------------
    _execute_ "defaults write com.apple.finder QuitMenuItem -bool true" "Finder: allow quitting via ⌘ + Q"

    _execute_ "defaults write com.apple.finder DisableAllAnimations -bool true" "Finder: disable window animations and Get Info animations"

    # For other paths, use `PfLo` and `file:///full/path/here/`
    _execute_ "defaults write com.apple.finder NewWindowTarget -string \"PfHm\"" "Set Home Folder as the default location for new Finder windows 1"
    _execute_ "defaults write com.apple.finder NewWindowTargetPath -string \"file://${HOME}/\"" "Set Home Folder as the default location for new Finder windows 2"

    success "Show icons for External hard drives, servers, and removable media on the desktop"
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
    # defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

    #success "Finder: show hidden files by default"
    #defaults write com.apple.finder AppleShowAllFiles -bool true

    success "Finder: show all filename extensions"
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # success "Finder: show status bar"
    # defaults write com.apple.finder ShowStatusBar -bool true

    success "Finder: show path bar"
    defaults write com.apple.finder ShowPathbar -bool true

    success "Finder: allow text selection in Quick Look"
    defaults write com.apple.finder QLEnableTextSelection -bool true

    #success "Display full POSIX path as Finder window title"
    #defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

    success "When performing a search, search the current folder by default"
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    success "Disable the warning when changing a file extension"
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    success "Enable spring loading for directories"
    defaults write NSGlobalDomain com.apple.springing.enabled -bool true

    success "Remove the spring loading delay for directories"
    defaults write NSGlobalDomain com.apple.springing.delay -float 0

    success "Avoid creating .DS_Store files on network volumes"
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    success "Disable disk image verification"
    defaults write com.apple.frameworks.diskimages skip-verify -bool true
    defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
    defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

    success "Automatically open a new Finder window when a volume is mounted"
    defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
    defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
    defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

    # success "Show item info to the right of the icons on the desktop"
    # /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

    success "Enable snap-to-grid for icons on the desktop and in other icon views"
    /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

    success "Increase grid spacing for icons on the desktop and in other icon views"
    /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

    success "Increase the size of icons on the desktop and in other icon views"
    /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:iconSize 40" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set StandardViewSettings:IconViewSettings:iconSize 40" ~/Library/Preferences/com.apple.finder.plist

    success "Use icon view in all Finder windows by default"
    defaults write com.apple.finder FXPreferredViewStyle -string "icnv"
    # Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`, `Nlsv`

    # success "Disable the warning before emptying the Trash"
    # defaults write com.apple.finder WarnOnEmptyTrash -bool false

    # success "Empty Trash securely by default"
    # defaults write com.apple.finder EmptyTrashSecurely -bool true

    success "Show the ~/Library folder"
    chflags nohidden ${HOME}/Library

    success "Show the /Volumes folder"
    sudo chflags nohidden /Volumes

    success "Keep folders on top when sorting by name"
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    #success "Remove Dropbox’s green checkmark icons in Finder"
    #file=/Applications/Dropbox.app/Contents/Resources/emblem-dropbox-uptodate.icns
    #[ -e "${file}" ] && mv -f "${file}" "${file}.bak"

    success "Expand File Info panes"
    # “General”, “Open with”, and “Sharing & Permissions”
    defaults write com.apple.finder FXInfoPanesExpanded -dict \
      General -bool true \
      OpenWith -bool true \
      Privileges -bool true

    # Enable AirDrop over Ethernet and on unsupported Macs running Lion
    # defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

    # Dock & Dashboard Preferences
    # ---------------------------

    success "Enable highlight hover effect for the grid view of a stack"
    defaults write com.apple.dock mouse-over-hilite-stack -bool true

    success "Change minimize/maximize window effect"
    defaults write com.apple.dock mineffect -string "genie"

    success "Set the icon size of Dock items to 36 pixels"
    defaults write com.apple.dock tilesize -int 36

    success "Show only open applications in the Dock"
    defaults write com.apple.dock static-only -bool true

    success "Minimize windows into their application’s icon"
    defaults write com.apple.dock minimize-to-application -bool true

    success "Enable spring loading for all Dock items"
    defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

    success "Show indicator lights for open applications in the Dock"
    defaults write com.apple.dock show-process-indicators -bool true

    success "Wipe all (default) app icons from the Dock"
    # This is only really useful when setting up a new Mac, or if you don’t use
    # the Dock to launch apps.
    defaults write com.apple.dock persistent-apps -array

    success "Disable App Persistence (re-opening apps on login)"
    defaults write -g ApplePersistence -bool no

    success "Don’t animate opening applications from the Dock"
    defaults write com.apple.dock launchanim -bool false

    success "Speed up Mission Control animations"
    defaults write com.apple.dock expose-animation-duration -float 0.1

    # success "Don’t group windows by application in Mission Control"
    # # (i.e. use the old Exposé behavior instead)
    # defaults write com.apple.dock expose-group-by-app -bool false

    success "Disable Dashboard"
    defaults write com.apple.dashboard mcx-disabled -bool true

    success "Don’t show Dashboard as a Space"
    defaults write com.apple.dock dashboard-in-overlay -bool true

    # success "Don’t automatically rearrange Spaces based on most recent use"
    # defaults write com.apple.dock mru-spaces -bool false

    success "Remove the auto-hiding Dock delay"
    defaults write com.apple.dock autohide-delay -float 0

    success "Speed Up the animation when hiding/showing the Dock"
    defaults write com.apple.dock autohide-time-modifier -float 0.5

    success "Automatically hide and show the Dock"
    defaults write com.apple.dock autohide -bool true

    success "Make Dock icons of hidden applications translucent"
    defaults write com.apple.dock showhidden -bool true

    # Add a spacer to the left side of the Dock (where the applications are)
    #defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
    # Add a spacer to the right side of the Dock (where the Trash is)
    #defaults write com.apple.dock persistent-others -array-add '{tile-data={}; tile-type="spacer-tile";}'

    success "Disabled hot corners"
    # Possible values:
    #  0: no-op
    #  2: Mission Control
    #  3: Show application windows
    #  4: Desktop
    #  5: Start screen saver
    #  6: Disable screen saver
    #  7: Dashboard
    # 10: Put display to sleep
    # 11: Launchpad
    # 12: Notification Center
    # Top left screen corner → Mission Control
    defaults write com.apple.dock wvous-tl-corner -int 0
    defaults write com.apple.dock wvous-tl-modifier -int 0
    # Top right screen corner → Desktop
    defaults write com.apple.dock wvous-tr-corner -int 0
    defaults write com.apple.dock wvous-tr-modifier -int 0
    # Bottom left screen corner → Start screen saver
    defaults write com.apple.dock wvous-bl-corner -int 0
    defaults write com.apple.dock wvous-bl-modifier -int 0

    # Safari
    # ---------------------------
    success "Privacy: don’t send search queries to Apple"
    defaults write com.apple.Safari UniversalSearchEnabled -bool false
    defaults write com.apple.Safari SuppressSearchSuggestions -bool true

    success "Show the full URL in the address bar (note: this still hides the scheme)"
    defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

    success "Set Safari’s home page to about:blank for faster loading"
    defaults write com.apple.Safari HomePage -string "about:blank"

    success "Prevent Safari from opening safe files automatically after downloading"
    defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

    # success "Allow hitting the Backspace key to go to the previous page in history"
    # defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

    # # Hide Safari’s bookmarks bar by default
    # defaults write com.apple.Safari ShowFavoritesBar -bool false

    # # Hide Safari’s sidebar in Top Sites
    # defaults write com.apple.Safari ShowSidebarInTopSites -bool false

    # # Disable Safari’s thumbnail cache for History and Top Sites
    # defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

    success "Enable Safari’s debug menu"
    defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

    success "Make Safari’s search banners default to Contains instead of Starts With"
    defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

    success "Remove useless icons from Safari’s bookmarks bar"
    defaults write com.apple.Safari ProxiesInBookmarksBar "()"

    success "Enable the Develop menu and the Web Inspector in Safari"
    defaults write com.apple.Safari IncludeDevelopMenu -bool true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

    success "Add a context menu item for showing the Web Inspector in web views"
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

    # Mail.app Preferences
    # ---------------------------

    success "Disable send and reply animations in Mail.app"
    defaults write com.apple.mail DisableReplyAnimations -bool true
    defaults write com.apple.mail DisableSendAnimations -bool true

    success "Copy sane email addresses to clipboard"
    # Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
    defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

    #success "Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app"
    #defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" -string "@\\U21a9"

    success "Display emails in threaded mode, sorted by date (newest at the top)"
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "no"
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

    #success "Disable inline attachments (just show the icons)"
    #defaults write com.apple.mail DisableInlineAttachmentViewing -bool false

    # Time Machine Preferences
    # ---------------------------
    success "Prevent Time Machine from prompting to use new hard drives as backup volume"
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

    # success "Disable local Time Machine backups"
    # hash tmutil &> /dev/null && sudo tmutil disablelocal

    # Random Application Preferences
    # ---------------------------

    success "Show the main window when launching Activity Monitor"
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

    success "Visualize CPU usage in the Activity Monitor Dock icon"
    defaults write com.apple.ActivityMonitor IconType -int 5

    success "Show all processes in Activity Monitor"
    defaults write com.apple.ActivityMonitor ShowCategory -int 0

    success "Sort Activity Monitor results by CPU usage"
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0

    success "Stop Photos from opening whenever a camera is connected"
    defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool YES

    success "Configure Google Chrome"
    defaults write com.google.Chrome DisablePrintPreview -bool true
    defaults write com.google.Chrome.canary DisablePrintPreview -bool true

    success "Enable the debug menu in Address Book"
    defaults write com.apple.addressbook ABShowDebugMenu -bool true

    # Enable Dashboard dev mode (allows keeping widgets on the desktop)
    # defaults write com.apple.dashboard devmode -bool true

    # Enable the debug menu in iCal (pre-10.8)
    # defaults write com.apple.iCal IncludeDebugMenu -bool true

    success "Use plain text mode for new TextEdit documents"
    defaults write com.apple.TextEdit RichText -int 0

    success "Open and save files as UTF-8 in TextEdit"
    defaults write com.apple.TextEdit PlainTextEncoding -int 4
    defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

    success "Enable the debug menu in Disk Utility"
    defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
    defaults write com.apple.DiskUtility advanced-image-options -bool true

    success "Disable automatic emoji substitution in Messages.app (i.e. use plain text smileys)"
    defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

    success "Disable smart quotes in Messages.app (it's annoying for messages that contain code)"
    defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

    success "Disabled continuous spell checking in Messages.app"
    defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false
  fi

} # end _mainScript_

_sourceHelperFiles_() {
  local filesToSource
  local sourceFile

  filesToSource=(
    "${HOME}/dotfiles/scripting/helpers/baseHelpers.bash"
  )

  for sourceFile in "${filesToSource[@]}"; do
    [ ! -f "$sourceFile" ] \
      && {
        echo "error: Can not find sourcefile '$sourceFile'. Exiting."
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

This script sets the default system preferences for OSX


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
