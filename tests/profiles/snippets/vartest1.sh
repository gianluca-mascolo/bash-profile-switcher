# shellcheck shell=bash
case "$1" in
load)
    export check_var_test1="test1 variable"
    export common_value="test1 common"
    ;;
unload)
    unset check_var_test1
    unset common_value
    ;;
*)
    true
    ;;
esac

return 0
