#!/bin/bash
set -euo pipefail
export PIPPO="pippo:pluto:paperino"
snpt() {
    local -r snippet_cmd="${1:-}"
    local -r snippet_name="${2:-}"
    local -r REGEX="(^|.*:)(${snippet_name})(:.*|$)"
    local NEWPIPPO

    case "$snippet_cmd" in
    push)
        if [[ "$PIPPO" =~ $REGEX ]]; then return 0; else export PIPPO="${PIPPO}:${snippet_name}"; fi
        ;;
    pop)
        if [[ "$PIPPO" =~ $REGEX ]]; then NEWPIPPO="${BASH_REMATCH[1]%:}:${BASH_REMATCH[3]#:}"; else return 0; fi
        NEWPIPPO=${NEWPIPPO%:}
        export PIPPO=${NEWPIPPO#:}
        echo "NEWPIPPO|$NEWPIPPO * PIPPO|$PIPPO"

        ;;
    search)
        if [[ "$PIPPO" =~ $REGEX ]]; then return 0; else return 1; fi
        ;;
    *)
        echo "${PIPPO:-}"
        ;;
    esac
    return 0
}

echo "* 00"
snpt
echo "* 01"
snpt push minnie && echo "XX $PIPPO"
echo "* 02"
snpt push pisolina && echo "XX $PIPPO"
echo "* 03"
snpt search pippo && echo found
echo "* 04"
snpt search gambadilegno || echo notfound
echo "* 05"
snpt pop pisolina && echo "XX $PIPPO"
echo "* 06"
snpt pop pluto && echo "XX $PIPPO"
echo "* 07"
snpt pop pippo && echo "XX $PIPPO"
echo "* 08"
snpt
