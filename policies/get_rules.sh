#!/bin/bash


source ~/.env_apptrust

curl  -L -X GET \
    "${base_url}/rules"\
    -H "Authorization: Bearer $JF_TOKEN" \
    -H "Content-Type: application/json" \
    --fail-with-body \
    -o ~/tmp/rules.json