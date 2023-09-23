# shellcheck shell=bash

# name: dirtools.sh
# repository: https://github.com/gianluca-mascolo/bash-profile-switcher
# license: GPL-3.0-or-later
# provides:
#   - mkcd create a directory and cd into it
#   - pathctl manage PATH variable
# requires:
#   - realpath (from coreutils) to use pathctl

SNIPPET_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"
case "$1" in
load)
    _snippet search "$SNIPPET_NAME" && return 0
    # load your settings here >>>
    mkcd() { [ -d "$1" ] || mkdir "$1" && cd "$1" || return 0; }
    pathctl() {
        local PATH_CMD Option OPTIND OPTARG PATH_ELEMENT
        while getopts ":fldh" Option; do
            case $Option in
            f)
                PATH_CMD="first"
                break
                ;;
            l)
                PATH_CMD="last"
                break
                ;;
            d)
                PATH_CMD="delete"
                break
                ;;
            h)
                echo "${FUNCNAME[0]} [-f|-l|-d] <directory>"
                echo "  -f insert directory as first element of PATH"
                echo "  -l insert directory as last element of PATH"
                echo "  -d delete directory from PATH"
                echo -e "\nDirectory will be fully expanded with 'realpath' and inserted if it is not already present in PATH"
                echo -e "If no options are specified default is to append directory as last"
                return 0
                ;;
            *)
                echo "ERROR: Invalid option"
                pathctl -h
                return 1
                ;;
            esac
        done
        shift $((OPTIND - 1))
        PATH_CMD="${PATH_CMD:-last}"
        PATH_ELEMENT="${1:-}"
        if [[ "$PATH_ELEMENT" =~ ^(-[dfhl])$ ]]; then
            echo "ERROR: You must specify only one option between -f -l or -d"
            pathctl -h
            return 1
        fi
        if [ -z "${PATH_ELEMENT:+is_set}" ]; then
            echo "Error: missing path element"
            pathctl -h
            return 1
        fi
        if [ -d "$PATH_ELEMENT" ]; then
            PATH_ELEMENT="$(realpath "$PATH_ELEMENT")"
        else
            echo "ERROR: You must specify a valid directory"
            pathctl -h
            return 1
        fi
        local -r REGEX="(^|.*:)(${PATH_ELEMENT})(:.*|$)"
        case $PATH_CMD in
        first)
            [[ "$PATH" =~ $REGEX ]] || PATH="${PATH_ELEMENT}:${PATH}"
            ;;
        last)
            [[ "$PATH" =~ $REGEX ]] || PATH="${PATH}:${PATH_ELEMENT}"
            ;;
        delete)
            if [[ "$PATH" =~ $REGEX ]]; then PATH="${BASH_REMATCH[1]%:}:${BASH_REMATCH[3]#:}"; else return 0; fi
            PATH=${PATH%:}
            PATH=${PATH#:}
            ;;
        *)
            return 0
            ;;
        esac
        export PATH
        return 0
    }
    # <<<
    _snippet push "$SNIPPET_NAME" 2>/dev/null
    ;;
unload)
    _snippet search "$SNIPPET_NAME" || return 0
    # unload your settings here >>>
    unset -f mkcd
    unset -f path_append
    # <<<
    _snippet pop "$SNIPPET_NAME" 2>/dev/null
    ;;
*)
    true
    ;;
esac

return 0
