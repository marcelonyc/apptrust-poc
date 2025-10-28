#!/bin/bash

# READ !!!!!!!!!!!
# This script requires the id of the template
# You need to update it in rule.json
source ~/.env_apptrust
rule=`cat rule.json`

curl -sS -L -X POST \
    "${base_url}/rules"\
    -H "Authorization: Bearer $JF_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$rule" \
    --fail-with-body