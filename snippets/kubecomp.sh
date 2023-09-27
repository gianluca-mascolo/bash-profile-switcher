# shellcheck shell=bash

# name: kubecomp.sh
# repository: https://github.com/gianluca-mascolo/bash-profile-switcher
# license: GPL-3.0-or-later
# provides:
#   - kubectl command completion
# requires:
#   - kubectl installed for command completion

case "$1" in
load)
    hash kubectl && source <(kubectl completion bash)
    ;;
unload)
    declare -F | while read -r funcname; do [[ "$funcname" =~ kubectl ]] && unset -f "$funcname"; done
    complete -p kubectl &>/dev/null && complete -r kubectl
    ;;
*)
    true
    ;;
esac

return 0
