# shellcheck shell=bash
SNIPPET_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"
case "$1" in
load)
    _snippet search "$SNIPPET_NAME" && return 0
    # load your settings here >>>
    export var1="test1 variable"
    # <<<
    _snippet push "$SNIPPET_NAME" 2>/dev/null
    ;;
unload)
    _snippet search "$SNIPPET_NAME" || return 0
    # unload your settings here >>>
    unset var1
    # <<<
    _snippet pop "$SNIPPET_NAME" 2>/dev/null
    ;;
*)
    true
    ;;
esac

return 0
