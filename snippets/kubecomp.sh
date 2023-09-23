# shellcheck shell=bash

# name: kubecomp.sh
# repository: https://github.com/gianluca-mascolo/bash-profile-switcher
# license: GPL-3.0-or-later
# provides:
#   - kubectl command completion
# requires:
#   - kubectl installed for command completion

SNIPPET_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"
case "$1" in
load)
    _snippet search "$SNIPPET_NAME" && return 0
    # load your settings here >>>
    hash kubectl && source <(kubectl completion bash)
    # <<<
    _snippet push "$SNIPPET_NAME" 2>/dev/null
    ;;
unload)
    _snippet search "$SNIPPET_NAME" || return 0
    # unload your settings here >>>
    declare -F | while read -r funcname; do [[ "$funcname" =~ kubectl ]] && unset -f "$funcname"; done
    complete -p kubectl && complete -r kubectl
    # <<<
    _snippet pop "$SNIPPET_NAME" 2>/dev/null
    ;;
*)
    true
    ;;
esac

return 0
