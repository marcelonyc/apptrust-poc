#!/bin/bash


source ~/.env_apptrust

curl -sS -L -X GET \
    "${base_url}/templates"\
    -H "Authorization: Bearer $JF_TOKEN" \
    -H "Content-Type: application/json" \
    --fail-with-body \
    -o ~/tmp/templates.json