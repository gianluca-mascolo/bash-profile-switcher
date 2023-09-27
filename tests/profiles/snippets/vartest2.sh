# shellcheck shell=bash
case "$1" in
load)
    export check_var_test2="test2 variable"
    export common_value="test2 common"
    ;;
unload)
    unset check_var_test2
    unset common_value
    ;;
*)
    true
    ;;
esac

return 0
