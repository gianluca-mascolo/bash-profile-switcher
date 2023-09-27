# shellcheck shell=bash
case "$1" in
load)
    export var1="test1 variable"
    ;;
unload)
    unset var1
    ;;
*)
    true
    ;;
esac

return 0
