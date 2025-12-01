

## Table of Contents

1. [Create Template](#create-template)
  - [Command-line Arguments](#command-line-arguments)
  - [Environment Variables](#environment-variables)
  - [Usage](#usage)
  - [Error Handling](#error-handling)
2. [Rego Policy Testing with `rego_test.sh`](#rego-policy-testing-with-rego_testsh)
  - [Prerequisites](#prerequisites)
  - [Usage](#usage-1)
  - [Example](#example)
  - [Input Structure](#input-structure)
  - [Output](#output)
  - [Troubleshooting](#troubleshooting)
  - [Customization](#customization)


## Create Template

This script is used to create or update a template in AppTrust by replacing placeholders in a JSON template file with the content of a specified Rego file. The script reads
environment variables, processes the template, and sends HTTP requests to the AppTrust API.



***UPDATE TEMPLATE NOT WORKING YET***

Command-line Arguments:
------------------------
* template_json_path: Path to the template JSON file.
* template_id: (Optional - NOT OPERATIONAL YET) ID of the template to update. If not provided, a new template will be created.

Environment Variables:
-----------------------
- base_url: Base URL of the AppTrust API.
  https://\<JFrog URL>/unifiedpolicy/api/v1
- JF_TOKEN: Authorization token for the AppTrust API.

Usage:
------
1. Ensure the environment variables `base_url` and `JF_TOKEN` are set in the `~/.env_apptrust` file.
2. Prepare a JSON template file with a placeholder for the Rego file in the format `{{ rego_file: path_to_rego_file }}`.
3. Run the script with the required arguments:
   ```
   python create_template.py --template_json_path path_to_template.json [--template_id template_id]
   ```

Error Handling:
---------------
- The script exits with an error message if:
  - The environment variables file is not found.
  - The template JSON file cannot be read.
  - The Rego file placeholder is missing or the file cannot be read.
  - The HTTP request to the AppTrust API fails.

## Rego Policy Testing with `rego_test.sh`

This script helps you test Rego policies using OPA (Open Policy Agent) with sample attestation and parameter JSON files.

## Prerequisites

- [OPA](https://www.openpolicyagent.org/docs/latest/get-started/) installed (`brew install opa` on macOS)
- [jq](https://stedolan.github.io/jq/) installed for JSON manipulation

## Usage

```sh
./rego_test.sh <rego_policy_file> <attestations_json_file> [params_json_file] [debug]
```

- `<rego_policy_file>`: Path to your Rego policy file (e.g., `regos/rego_policy_intoto.rego`)
- `<attestations_json_file>`: Path to a sample attestation JSON file
- `[params_json_file]`: (Optional) Path to a parameters JSON file
- `[debug]`: (Optional) If set to `true`, prints all policy data instead of just the `allow` rule

### Example

Test a policy with attestation and parameters:

```sh
./rego_test.sh regos/rego_policy_intoto.rego test/dvr-rental-2.0.0-Evidence.json test/params.json
```

Test a policy with only attestation:

```sh
./rego_test.sh regos/rego_policy_intoto.rego test/dvr-rental-2.0.0-Evidence.json
```

Debug mode (shows all policy data):

```sh
./rego_test.sh regos/rego_policy_intoto.rego test/dvr-rental-2.0.0-Evidence.json test/params.json true
```

## Input Structure

**Attestation JSON**: 
Should match the expected structure as presented by AppTrust. See example test/dvr-rental-2.0.2-Evidence.json.

**Params JSON**: 
Should contain fields referenced in your policy, such as:

```json
  {
    "tests_required": "2"
  }
```

Note: All parameters should be tested as strings. Convert the value inside your rego.

## Output

- By default, the script prints the result of the `allow` rule from your policy.
- In debug mode, it prints all data from `data.curation.policies`.

## Troubleshooting

- If you see errors about missing fields, check your input JSON structure.
- If you get `jq: Unknown option --argfile`, upgrade `jq` or use the provided workaround.
- Use debug mode to inspect intermediate policy results.

## Customization

- Edit the script to change the rule being evaluated or to adjust input construction for your specific policy needs.

---

For more information on OPA and Rego, visit the [OPA documentation](https://www.openpolicyagent.org/docs/latest/).


