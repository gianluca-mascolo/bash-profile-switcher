# shellcheck shell=bash

# name: pytools.sh
# repository: https://github.com/gianluca-mascolo/bash-profile-switcher
# license: GPL-3.0-or-later
# provides:
#   - yaml2json: cat <file.yaml> | yaml2json
#   - json2yaml: cat <file.json> | json2yaml
# requires:
#   - python3 with yaml and json module installed

SNIPPET_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"
case "$1" in
load)
    _snippet search "$SNIPPET_NAME" 2>/dev/null && return 0
    # load your settings here >>>
    alias yaml2json="python -c 'import sys,json,yaml; json.dump(yaml.safe_load(sys.stdin),sys.stdout,indent=2)'"
    alias json2yaml="python -c 'import sys,json,yaml; yaml.dump(json.load(sys.stdin),sys.stdout,indent=2)'"
    # <<<
    _snippet push "$SNIPPET_NAME" 2>/dev/null
    ;;
unload)
    _snippet search "$SNIPPET_NAME" 2>/dev/null || return 0
    # unload your settings here >>>
    unalias yaml2json
    unalias json2yaml
    # <<<
    _snippet pop "$SNIPPET_NAME" 2>/dev/null
    ;;
*)
    true
    ;;
esac

return 0
