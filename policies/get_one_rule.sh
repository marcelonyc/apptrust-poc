#!/bin/bash


source ~/.env_apptrust
rule=`cat rule.json`

curl -sS -L -X GET \
    "${base_url}/rules/1983154743520079872"\
    -H "Authorization: Bearer $JF_TOKEN" \
    -H "Content-Type: application/json" \
    --fail-with-body 