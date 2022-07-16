# shellcheck shell=bash
# Bash profile switcher

# bash-profile-switcher.sh
#
# Manage multiple environments using profile files
# and loading dynamically with bash shell.
#
# Append or source this snippet at the end of your ~/.bashrc
# Use switch_profile function to load custom profiles
#
# Source repository: https://github.com/gianluca-mascolo/bash-profile-switcher
#
# Copyright (C) 2022 Gianluca Mascolo
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

### GENERAL CONFIGURATION ###

# Setup default directory
export SWITCH_PROFILE_DIRECTORY=".bash_profiles"
[ -d "$HOME/$SWITCH_PROFILE_DIRECTORY" ] || mkdir "$HOME/$SWITCH_PROFILE_DIRECTORY"
# Setup save profile filename
export SWITCH_PROFILE_SAVED=".bash_saved_profile"

# Setup aliases to manage profiles
alias _load_bash_profile='eval [ -f "$HOME/$SWITCH_PROFILE_DIRECTORY/${BASH_CURRENT_PROFILE}.load" ] && source "$HOME/$SWITCH_PROFILE_DIRECTORY/${BASH_CURRENT_PROFILE}.load"'
alias _unload_bash_profile='eval [ -f "$HOME/$SWITCH_PROFILE_DIRECTORY/${BASH_CURRENT_PROFILE}.unload" ] && source "$HOME/$SWITCH_PROFILE_DIRECTORY/${BASH_CURRENT_PROFILE}.unload"'
alias _save_bash_profile='eval echo "export BASH_CURRENT_PROFILE=$SELECTED_PROFILE" > "$HOME/$SWITCH_PROFILE_SAVED"'
alias _reset_bash_profile='eval echo "unset BASH_CURRENT_PROFILE" > "$HOME/$SWITCH_PROFILE_SAVED"'

# Create list of profiles from .load files
_switch_profile_list() {
    local PROFILE_LIST
    # Note: If there are no matching files, echo *.load output literally "*.load"
    PROFILE_LIST="$(echo "$HOME/$SWITCH_PROFILE_DIRECTORY/"*.load)"
    PROFILE_LIST="${PROFILE_LIST//$HOME\/$SWITCH_PROFILE_DIRECTORY\//}"
    PROFILE_LIST="${PROFILE_LIST//.load/}"
    [ "$PROFILE_LIST" = '*' ] && PROFILE_LIST=""
    echo "$PROFILE_LIST"
}

SWITCH_PROFILE_LIST=$(_switch_profile_list)
export SWITCH_PROFILE_LIST

### FUNCTION DECLARATION ###
_switch_profile_help() {
    cat <<EOF
switch_profile [options] profile

OPTIONS
  -k
    Keep env. Load selected profile without unloading current environment.
  -d
    Don't load profile. Unload current profile and don't load any profile in new bash shells
  -t
    Temporary profile. Load selected profile in current shell without starting it in new bash shells
  -l
    List available profiles
  -h Show help instructions (this help)

PROFILE
  A profile to load in ~/.bash_profiles. Profile files end with extension '.load' for loading (set variables) and '.unload' for unloading (unset variables)
  Current profile is stored in environment variable BASH_CURRENT_PROFILE and in file ~/.bash_saved_profile

Example:

  ~]$ switch_profile dev

  To load profile dev from ~/.bash_profiles/dev.load and unload it from ~/.bash_profiles/dev.unload

EOF
}

switch_profile() {
    local OPTIND OPTARG SELECTED_PROFILE KEEP_ENV TEMP_PROFILE

    KEEP_ENV=0
    TEMP_PROFILE=0
    while getopts "tkdhl" Option; do
        case $Option in
        k)
            KEEP_ENV=1
            ;;
        t)
            TEMP_PROFILE=1
            ;;
        l)
            SWITCH_PROFILE_LIST=$(_switch_profile_list)
            export SWITCH_PROFILE_LIST
            [ -n "$SWITCH_PROFILE_LIST" ] && complete -o nospace -W "$SWITCH_PROFILE_LIST" switch_profile
            echo "Available profiles:"
            echo -e "${SWITCH_PROFILE_LIST// /\\n}"
            return 0
            ;;
        h)
            _switch_profile_help
            return 0
            ;;
        d)
            _unload_bash_profile
            _reset_bash_profile
            exec bash
            ;;
        *)
            _switch_profile_help
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    SELECTED_PROFILE="$1"
    if [ -f "${HOME}/${SWITCH_PROFILE_DIRECTORY}/${SELECTED_PROFILE}.load" ]; then {
        [ $KEEP_ENV -eq 0 ] && _unload_bash_profile
        if [ $TEMP_PROFILE -eq 0 ]; then _save_bash_profile; else export BASH_NEXT_PROFILE="$SELECTED_PROFILE"; fi
        exec bash
    }; else
        {
            _switch_profile_help
            echo "Selected profile does not exist."
            switch_profile -l
            echo ""
            return 1
        }
    fi
}

#
### MAIN SCRIPT ###
[ -n "$SWITCH_PROFILE_LIST" ] && complete -o nospace -W "$SWITCH_PROFILE_LIST" switch_profile

if [ -z ${BASH_NEXT_PROFILE+is_set} ]; then {
    if [ -f "$HOME/$SWITCH_PROFILE_SAVED" ]; then
        {
            # shellcheck source=/dev/null
            source "$HOME/$SWITCH_PROFILE_SAVED"
            [ -n "${BASH_CURRENT_PROFILE+is_set}" ] && _load_bash_profile
        }
    fi
}; else
    {
        export BASH_CURRENT_PROFILE="$BASH_NEXT_PROFILE"
        unset BASH_NEXT_PROFILE
        _load_bash_profile
    }
fi
