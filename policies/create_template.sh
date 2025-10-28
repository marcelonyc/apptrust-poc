#!/bin/bash

source ~/.env_apptrust
template=`cat template.json`

curl -sS -L -X POST \
    "${base_url}/templates"\
    -H "Authorization: Bearer $JF_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$template" \
    --fail-with-body