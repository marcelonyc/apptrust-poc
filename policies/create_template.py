import sys
import os
import re
import json
import requests
from dotenv import load_dotenv
import argparse


def create_or_update_template(
    base_url, JF_TOKEN, generated_template, template_id=None
):
    headers = {
        "Authorization": f"Bearer {JF_TOKEN}",
        "Content-Type": "application/json",
    }
    if template_id:
        log("info", f"Updating template with ID {template_id} in AppTrust...")
        url = f"{base_url}/templates/{template_id}"
        response = requests.put(url, headers=headers, data=generated_template)
    else:
        log("info", "Creating template in AppTrust...")
        url = f"{base_url}/templates"
        response = requests.post(url, headers=headers, data=generated_template)

    if not response.ok:
        log(
            "error",
            f"Failed to {'update' if template_id else 'create'} template in AppTrust: {response.text}",
        )
    else:
        log(
            "success",
            f"Template {'updated' if template_id else 'created'} successfully.",
        )


def log(type_, message):
    from datetime import datetime

    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    icons = {
        "info": "📘",
        "success": "✅",
        "warning": "⚠️",
        "error": "❌",
        "log": "📝",
    }
    colors = {
        "info": "\033[1;34m",
        "success": "\033[1;32m",
        "warning": "\033[1;33m",
        "error": "\033[1;31m",
        "log": "\033[1;37m",
    }
    color = colors.get(type_, colors["log"])
    icon = icons.get(type_, icons["log"])
    print(f"{color}[{type_.upper()}] [{timestamp}] {icon}\033[0m {message}")
    if type_ == "error":
        sys.exit(1)


def main(template_json_path, template_id=None, verbose=False):
    # Load environment variables using python-dotenv

    env_path = os.path.expanduser("~/.env_apptrust")
    if os.path.exists(env_path):
        load_dotenv(env_path)
    else:
        log("error", "Failed to source environment variables.")

    # Read template file
    try:
        with open(template_json_path) as f:
            template = f.read()
    except Exception as e:
        log("error", f"Failed to read template file: {template_json_path}")

    # Find rego_file placeholder
    match = re.search(r"{{\s*rego_file:\s*([^}]+)\s*}}", template)
    if not match:
        log("error", "No rego_file placeholder found in the template.")
    rego_file_path = match.group(1).strip()

    # Read rego file and replace newlines with \n
    try:
        with open(rego_file_path, "r") as file:
            rego_content = (
                file.read()
                .replace("\n", "\\n")
                .replace("\r", "\\n")
                .replace('"', '\\"')
                .replace("\t", "")
            )

    except Exception as e:
        log("error", f"Failed to read Rego file: {rego_file_path}")

    generated_template = template.replace(
        f"{{{{ rego_file: {rego_file_path} }}}}", rego_content
    )
    if verbose:
        log("info", f"Generated Template: {generated_template}")

    base_url = os.environ.get("base_url")
    JF_TOKEN = os.environ.get("JF_TOKEN")
    create_or_update_template(
        base_url, JF_TOKEN, generated_template, template_id
    )


if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        description="Create a template in AppTrust."
    )
    parser.add_argument(
        "--template_json_path",
        type=str,
        help="Path to the template JSON file.",
    )

    parser.add_argument(
        "--verbose",
        "-v",
        type=bool,
        help="Enable verbose output.",
    )

    parser.add_argument(
        "--template_id",
        type=str,
        help="ID of the template to update. If not provided, a new template will be created.",
    )
    args = parser.parse_args()

    main(args.template_json_path, args.template_id, args.verbose)
