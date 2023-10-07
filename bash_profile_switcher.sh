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
export SWITCH_PROFILE_DIRECTORY=".bash_profile.d"
[ -d "$HOME/$SWITCH_PROFILE_DIRECTORY" ] || mkdir "$HOME/$SWITCH_PROFILE_DIRECTORY"
[ -d "$HOME/$SWITCH_PROFILE_DIRECTORY/snippets" ] || mkdir "$HOME/$SWITCH_PROFILE_DIRECTORY/snippets"

# Setup save profile filename
export SWITCH_PROFILE_SAVED=".bash_saved_profile"

# List of loaded snippets separated by colon like
# snipname1:snipname2:snippetname3
export SWITCH_PROFILE_SNIPPETS=""

# Setup aliases to manage profiles
alias _save_bash_profile='eval echo "export SWITCH_PROFILE_CURRENT=$SELECTED_PROFILE" > "$HOME/$SWITCH_PROFILE_SAVED"'

alias _get_snippets='eval unset LOAD_SNIPPETS; declare -a LOAD_SNIPPETS; mapfile -c 1 -C _parse_profile -t <"${HOME}/${SWITCH_PROFILE_DIRECTORY}/${SWITCH_PROFILE_CURRENT}.profile"'
# shellcheck disable=SC2154
alias _load_bash_profile='_get_snippets; for ((n=0;n<${#LOAD_SNIPPETS[*]};n++)); do if ! _snippet search "$(basename "${LOAD_SNIPPETS[$n]}" .sh)"; then source "${LOAD_SNIPPETS[$n]}" load && _snippet push "$(basename "${LOAD_SNIPPETS[$n]}" .sh)"; fi; done'

# _parse_profile
# To be used with mapfile
# Every line in the file is parsed and checked for a corresponding snippet to be loaded
# It will store the valid snippets in global array LOAD_SNIPPETS
_parse_profile() {
    local VALUE
    local SNIPPET
    VALUE="$2"
    if [[ "$VALUE" =~ ^[[:blank:]]*([^# ]+)([[:blank:]]|$) ]]; then
        {
            SNIPPET="${BASH_REMATCH[1]}"
            [ -f "$HOME/$SWITCH_PROFILE_DIRECTORY/snippets/$SNIPPET.sh" ] && LOAD_SNIPPETS+=("$HOME/$SWITCH_PROFILE_DIRECTORY/snippets/$SNIPPET.sh")
        }
    fi
    return 0
}

# _snippet [push|pop|search] <snippet name>
# Manage the status of snippets storing it in SWITCH_PROFILE_SNIPPETS if it has loaded or unloaded.
# - push the snippet name into SWITCH_PROFILE_SNIPPETS only if the value is not already present
# - pop the snippet name from SWITCH_PROFILE_SNIPPETS
# - search if a snippet name is present in SWITCH_PROFILE_SNIPPETS
_snippet() {
    local -r snippet_cmd="${1:-}"
    local -r snippet_name="${2:-}"
    local -r REGEX="(^|.*:)(${snippet_name})(:.*|$)"

    case "$snippet_cmd" in
    push)
        if [[ "$SWITCH_PROFILE_SNIPPETS" =~ $REGEX ]]; then return 0; else SWITCH_PROFILE_SNIPPETS="${SWITCH_PROFILE_SNIPPETS}:${snippet_name}"; fi
        export SWITCH_PROFILE_SNIPPETS=${SWITCH_PROFILE_SNIPPETS#:}
        ;;
    pop)
        if [[ "$SWITCH_PROFILE_SNIPPETS" =~ $REGEX ]]; then SWITCH_PROFILE_SNIPPETS="${BASH_REMATCH[1]%:}:${BASH_REMATCH[3]#:}"; else return 0; fi
        SWITCH_PROFILE_SNIPPETS=${SWITCH_PROFILE_SNIPPETS%:}
        export SWITCH_PROFILE_SNIPPETS=${SWITCH_PROFILE_SNIPPETS#:}
        ;;
    search)
        if [[ "$SWITCH_PROFILE_SNIPPETS" =~ $REGEX ]]; then return 0; else return 1; fi
        ;;
    *)
        echo "${SWITCH_PROFILE_SNIPPETS:-}"
        ;;
    esac
    return 0
}

# Create list of profiles from .profile files
_switch_profile_list() {
    local PROFILE_LIST
    # Note: If there are no matching files, echo *.profile output literally "*.profile"
    PROFILE_LIST="$(echo "$HOME/$SWITCH_PROFILE_DIRECTORY/"*.profile)"
    PROFILE_LIST="${PROFILE_LIST//$HOME\/$SWITCH_PROFILE_DIRECTORY\//}"
    PROFILE_LIST="${PROFILE_LIST//.profile/}"
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
  A profile to load in ~/$SWITCH_PROFILE_DIRECTORY. Profile files end with extension '.profile' and contains a list of snippets to be loaded.
  Current profile is stored in environment variable SWITCH_PROFILE_CURRENT and in file ~/$SWITCH_PROFILE_SAVED

SNIPPETS

  Snippets are .sh files located in ~/$SWITCH_PROFILE_DIRECTORY/snippets that accept load or unload as first positional parameter (\$1)
  Each snippet will be included with source in your shell.

EXAMPLE

  Given the following setup ~/$SWITCH_PROFILE_DIRECTORY
  ~]$ tree ~/.bash_profile.d/
    $HOME/.bash_profile.d/
    ├── dev.profile
    └── snippets
        ├── snip1.sh
        └── snip2.sh

  ~]$ cat ~/.bash_profile.d/dev.profile
    snip1
    snip2

  ~]$ switch_profile dev

  snip1.sh and snip2.sh will be included into your bash shell.

ADDENDUM

  - Snippets will be loaded in the order the are listed into profile file.
  - When you switch into a profile snippets are loaded with source command e.g. 'source snip1 load'
  - When you change profile, current snippets are unloaded (except if you use -k) in reverse order
    they are listed into profile file with source e.g. 'source snip1 unload'


EOF
}

switch_profile() {
    local OPTIND OPTARG SELECTED_PROFILE KEEP_ENV TEMP_PROFILE RESET_PROFILE

    KEEP_ENV=0
    TEMP_PROFILE=0
    RESET_PROFILE=0
    while getopts ":tkdhl" Option; do
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
            echo -e "${SWITCH_PROFILE_LIST// /\\n}"
            return 0
            ;;
        h)
            _switch_profile_help
            return 0
            ;;
        d)
            RESET_PROFILE=1
            ;;
        *)
            _switch_profile_help
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    if ! [ $KEEP_ENV -eq 1 ]; then
        #[ -f "$HOME/$SWITCH_PROFILE_DIRECTORY/snippets/$SNIPPET.sh" ]
        for ((n = -1; n >= -${#LOAD_SNIPPETS[*]}; n--)); do
            if _snippet search "$(basename "${LOAD_SNIPPETS[$n]}" .sh)"; then
                # shellcheck source=/dev/null
                source "${LOAD_SNIPPETS[$n]}" unload && _snippet pop "$(basename "${LOAD_SNIPPETS[$n]}" .sh)"
            fi
        done
    fi
    if [ $RESET_PROFILE -eq 1 ]; then
        echo "unset SWITCH_PROFILE_CURRENT" >"$HOME/$SWITCH_PROFILE_SAVED"
        exec bash
    fi

    SELECTED_PROFILE="$1"
    if [ -f "${HOME}/${SWITCH_PROFILE_DIRECTORY}/${SELECTED_PROFILE}.profile" ]; then {
        if [ $TEMP_PROFILE -eq 0 ]; then _save_bash_profile; else export SWITCH_PROFILE_NEXT="$SELECTED_PROFILE"; fi
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

### MAIN SCRIPT ###
[ -n "$SWITCH_PROFILE_LIST" ] && complete -o nospace -W "$SWITCH_PROFILE_LIST" switch_profile

if [ -z ${SWITCH_PROFILE_NEXT+is_set} ]; then {
    if [ -f "$HOME/$SWITCH_PROFILE_SAVED" ]; then
        {
            # shellcheck source=/dev/null
            source "$HOME/$SWITCH_PROFILE_SAVED"
        }
    fi
}; else
    {
        export SWITCH_PROFILE_CURRENT="$SWITCH_PROFILE_NEXT"
        unset SWITCH_PROFILE_NEXT
    }
fi

if [ -n "${SWITCH_PROFILE_CURRENT+is_set}" ]; then _load_bash_profile; fi
