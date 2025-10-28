#!/bin/bash

source ~/.env_apptrust
curl -sS -L -X DELETE \
    "${base_url}/rules/1975307256007249920"\
    -H "Authorization: Bearer $JF_TOKEN" \
    -H "Content-Type: application/json" \
    --fail-with-body \
