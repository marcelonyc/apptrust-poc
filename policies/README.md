***
This script is used to create or update a template in AppTrust by replacing placeholders
in a JSON template file with the content of a specified Rego file. The script reads
environment variables, processes the template, and sends HTTP requests to the AppTrust API.
***


***UPDATE TEMPLATE NOT WORKING YET***

Functions:
-----------
- create_or_update_template(base_url, JF_TOKEN, generated_template, template_id=None):
    Sends an HTTP POST or PUT request to create or update a template in AppTrust.

- log(type_, message):
    Logs messages to the console with different severity levels (info, success, warning, error, log).

- main(template_json_path, template_id=None):
    Main function that orchestrates the process of reading the template, replacing placeholders,
    and calling the create_or_update_template function.

Command-line Arguments:
------------------------
- --template_json_path: Path to the template JSON file.
- --template_id: (Optional) ID of the template to update. If not provided, a new template will be created.

Environment Variables:
-----------------------
- base_url: Base URL of the AppTrust API.
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
"""