# Bash profile switcher

# bash-profile-switcher.sh
#
# Manage multiple environments using profile files
# and loading dynamically with bash shell.
#
# Append or source this snippet at the end of your ~/.bashrc
# Use switch_profile function to load custom profiles

# Copyright (C) 2022 Gianluca Mascolo

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

### GENERAL CONFIGURATION ###

# Setup default directory
export SWITCH_PROFILE_DIRECTORY=".bash_profiles"
[ -d "$HOME/$SWITCH_PROFILE_DIRECTORY" ] || mkdir "$HOME/$SWITCH_PROFILE_DIRECTORY"

# Setup aliases to manage profiles
alias load_bash_profile='eval [ -f "$HOME/$SWITCH_PROFILE_DIRECTORY/${BASH_CURRENT_PROFILE}.load" ] && source "$HOME/$SWITCH_PROFILE_DIRECTORY/${BASH_CURRENT_PROFILE}.load"'
alias unload_bash_profile='eval [ -f "$HOME/$SWITCH_PROFILE_DIRECTORY/${BASH_CURRENT_PROFILE}.unload" ] && source "$HOME/$SWITCH_PROFILE_DIRECTORY/${BASH_CURRENT_PROFILE}.unload"'
alias save_bash_profile='eval echo "export BASH_CURRENT_PROFILE=$SELECTED_PROFILE" > "$HOME/$SWITCH_PROFILE_DIRECTORY/saved_profile"'
alias reset_bash_profile='eval echo "unset BASH_CURRENT_PROFILE" > "$HOME/$SWITCH_PROFILE_DIRECTORY/saved_profile"'

# Create list of profiles from .load files

# Note: If there are no matching files, echo *.load output literally "*.load"
SWITCH_PROFILE_LIST="$(cd "$HOME/$SWITCH_PROFILE_DIRECTORY"; echo *.load)" 
SWITCH_PROFILE_LIST="${SWITCH_PROFILE_LIST//.load/}"
[ "$SWITCH_PROFILE_LIST" = '*' ] && SWITCH_PROFILE_LIST="" 
export SWITCH_PROFILE_LIST

_switch_profile_help () {
cat << EOF
switch_profile [options] profile

OPTIONS
  -k
    Keep env. Load selected profile without unloading current environment.
  -d
    Don't load any profile in new bash shells. Delete ~/.bash_profiles/current_profile.
  -t
    Temporary profile. Load selected profile in current shell without starting it in new bash shells
  -l
    List available profiles
  -h Show help instructions (this help)

PROFILE
  A profile to load in ~/.bash_profiles. Profile files end with extension '.load' for loading (set variables) and '.unload' for unloading (unset variables)
  Current profile is stored in environment variable BASH_CURRENT_PROFILE and in file ~/.bash_profiles/current_profile

Example:

  ~]$ switch_profile dev

  To load profile dev from ~/.bash_profiles/dev.load and unload it from ~/.bash_profiles/dev.unload

EOF
}

switch_profile () {
  local OPTIND OPTARG SELECTED_PROFILE KEEP_ENV DELETE_PROFILE TEMP_PROFILE

  KEEP_ENV=0
  DELETE_PROFILE=0
  TEMP_PROFILE=0
  while getopts "tkdhl" Option
  do
    case $Option in
      k)
        KEEP_ENV=1
      ;;
      t)
        TEMP_PROFILE=1
      ;;
      l)
        echo "Available profiles:"
        echo -e "${SWITCH_PROFILE_LIST// /\\n}"
	return 0
      ;;
      h)
        _switch_profile_help
        return 0
      ;;
      d)
        DELETE_PROFILE=1
      ;;
      *)
        _switch_profile_help
        return 1
      ;;
    esac
  done
  shift $(($OPTIND - 1))

  SELECTED_PROFILE="$1"
  [ $DELETE_PROFILE -eq 1 ] && SELECTED_PROFILE="$BASH_CURRENT_PROFILE"
  if ( [ -f "${HOME}/${SWITCH_PROFILE_DIRECTORY}/${SELECTED_PROFILE}.load" ] ); then {
     [ $KEEP_ENV -eq 0 ] && unload_bash_profile
     if ( [ $DELETE_PROFILE -eq 0 ] ); then {
      if ( [ $TEMP_PROFILE -eq 0 ] ); then save_bash_profile; else export BASH_NEXT_PROFILE="$SELECTED_PROFILE"; fi
      } else {
        reset_bash_profile
      }
     fi
     exec bash
  } else {
     echo "Selected profile does not exist."
     switch_profile -l
     echo ""
     _switch_profile_help
     return 1
  }
  fi
}

[ -n "$SWITCH_PROFILE_LIST" ] && complete -W "$SWITCH_PROFILE_LIST" switch_profile

if ( [ -z ${BASH_NEXT_PROFILE+is_set} ] ); then {
  if ( [ -f "$HOME/$SWITCH_PROFILE_DIRECTORY/saved_profile" ] ); then {
    source "$HOME/$SWITCH_PROFILE_DIRECTORY/saved_profile"
    [ -n "${BASH_CURRENT_PROFILE+is_set}" ] && load_bash_profile
  }
  fi
} else {
    export BASH_CURRENT_PROFILE="$BASH_NEXT_PROFILE"
    unset BASH_NEXT_PROFILE
    load_bash_profile
}
fi
