# Bash profile switcher

# Append or source this snippet at the end of your ~/.bashrc

# Create one or more load file under ~/.bash_profiles with your desired bash customizations
# for example:
# ~/.bash_profiles/dev.load
# ~/.bash_profiles/mymode.load
#
# Optionally create unload files under ~/.bash_profiles/
#
# Example: dev.load
# export PS1="Funky Prompt:: \w ]\\$ "
# Example: dev.unload
# unset PS1

# select a profile with
# switch_profile <profile name>
#
# Current selected profile is stored in environment variable BASH_CURRENT_PROFILE
# and in file ~/.bash_profiles/current_profile

export SWITCH_PROFILE_DIRECTORY=".bash_profiles"
[ -d "$HOME/$SWITCH_PROFILE_DIRECTORY" ] || mkdir "$HOME/$SWITCH_PROFILE_DIRECTORY"

alias load_bash_profile='eval [ -f "$HOME/$SWITCH_PROFILE_DIRECTORY/${BASH_CURRENT_PROFILE}.load" ] && source "$HOME/$SWITCH_PROFILE_DIRECTORY/${BASH_CURRENT_PROFILE}.load"'
alias unload_bash_profile='eval [ -f "$HOME/$SWITCH_PROFILE_DIRECTORY/${BASH_CURRENT_PROFILE}.unload" ] && source "$HOME/$SWITCH_PROFILE_DIRECTORY/${BASH_CURRENT_PROFILE}.unload"'
alias save_bash_profile='eval echo "export BASH_CURRENT_PROFILE=$SELECTED_PROFILE" > "$HOME/$SWITCH_PROFILE_DIRECTORY/saved_profile"'
alias reset_bash_profile='eval echo "unset BASH_CURRENT_PROFILE" > "$HOME/$SWITCH_PROFILE_DIRECTORY/saved_profile"'

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
  [ $DELETE_PROFILE -eq 1 ] && SELECTED_PROFILE=$BASH_CURRENT_PROFILE
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
