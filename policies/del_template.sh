#!/bin/bash -x

source ~/.env_apptrust
curl -sS -L -X DELETE \
    "${base_url}/templates/${1}"\
    -H "Authorization: Bearer $JF_TOKEN" \
    -H "Content-Type: application/json" \
    --fail-with-body 
