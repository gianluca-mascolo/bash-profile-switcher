# shellcheck shell=bash

# name: awscomp.sh
# repository: https://github.com/gianluca-mascolo/bash-profile-switcher
# license: GPL-3.0-or-later
# provides:
#   - aws cli command completion
#   - awp to switch between aws profiles exporting the AWS_PROFILE variable
# requires:
#   - aws cli installed for command completion
#   - fzf https://github.com/junegunn/fzf#using-linux-package-managers for awp

SNIPPET_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"
case "$1" in
load)
    _snippet search "$SNIPPET_NAME" && return 0
    # load your settings here >>>
    alias awp='eval export AWS_PROFILE=$(grep --color=none -oP "(?<=\[profile )[^]]+(?=])" "${AWS_CONFIG_FILE:-$HOME/.aws/config}" | sort | fzf --height=6)'
    hash aws_completer && complete -C "$(hash -t aws_completer)" aws
    # <<<
    _snippet push "$SNIPPET_NAME" 2>/dev/null
    ;;
unload)
    _snippet search "$SNIPPET_NAME" || return 0
    # unload your settings here >>>
    unalias awp
    complete -p aws && complete -r aws
    # <<<
    _snippet pop "$SNIPPET_NAME" 2>/dev/null
    ;;
*)
    true
    ;;
esac

return 0
