#!/bin/bash

RULES_FILE=${1}
# READ !!!!!!!!!!!
# This script requires the id of the template
# You need to update it in rule.json
source ~/.env_apptrust
rule=`cat ${RULES_FILE}`

curl -sS -L -X POST \
    "${base_url}/rules"\
    -H "Authorization: Bearer $JF_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$rule" \
    --fail-with-body