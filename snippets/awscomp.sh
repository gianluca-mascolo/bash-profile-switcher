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

case "$1" in
load)
    alias awp='eval export AWS_PROFILE=$(grep --color=none -oP "(?<=\[profile )[^]]+(?=])" "${AWS_CONFIG_FILE:-$HOME/.aws/config}" | sort | fzf --height=6)'
    hash aws_completer && complete -C "$(hash -t aws_completer)" aws
    ;;
unload)
    unalias awp
    complete -p aws &>/dev/null && complete -r aws
    ;;
*)
    true
    ;;
esac

return 0
