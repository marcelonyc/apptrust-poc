#!/bin/bash 

# Usage: ./test_rego.sh <rego_policy_file> <attestations_json_file> [params_json_file]
# Example: ./test_rego.sh rego_policy_intoto.rego sample_attestations.json params.json

REGO_POLICY="$1"
ATTESTATIONS_JSON="$2"
PARAMS_JSON="$3"

if [[ -z "$REGO_POLICY" || -z "$ATTESTATIONS_JSON" ]]; then
    echo "Usage: $0 <rego_policy_file> <attestations_json_file> [params_json_file]"
    exit 1
fi

# Build input JSON

if [[ -z "$PARAMS_JSON" ]]; then
    INPUT_JSON=$(jq -n --slurpfile data "$ATTESTATIONS_JSON" '{data: $data[0]}')
else
    echo "Using params file: $PARAMS_JSON"
    INPUT_JSON=$(jq -n --slurpfile data "$ATTESTATIONS_JSON" --slurpfile params "$PARAMS_JSON" '{data: $data[0].data.releaseBundleVersion.getVersion, params: $params[0]}')

fi

# echo "Input to OPA:"
# echo "$INPUT_JSON"

# Run OPA test
echo "OPA result:"
opa eval --input <(echo "$INPUT_JSON") --data "$REGO_POLICY" 'data.curation.policies'
