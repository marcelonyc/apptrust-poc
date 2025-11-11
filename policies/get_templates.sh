#!/bin/bash -x


source ~/.env_apptrust
rule=`cat rule.json`

curl -sS -L -X GET \
    "${base_url}/templates"\
    -H "Authorization: Bearer $JF_TOKEN" \
    -H "Content-Type: application/json" \
    --fail-with-body \
    -o ~/tmp/templates.json