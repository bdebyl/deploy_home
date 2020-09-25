#!/bin/sh
export YML_FILES="$(find ansible/ -name '*.yml' -not -name '*vault*')"

# Source the lint variables file (shared with Makefile)
. ./.lint-vars.sh
ansible-lint -x "$ANSIBLE_LINT_SKIP_LIST" $YML_FILES
yamllint $YML_FILES
