import os
import json
import readline
import requests
from rich import print as rprint
from rich.table import Table
from dotenv import load_dotenv

# Load environment variables from ~/.env_apptrust
load_dotenv(os.path.expanduser("~/.env_apptrust"))

BASE_URL = os.environ.get("base_url")
JF_TOKEN = os.environ.get("JF_TOKEN")


def fetch_templates():
    headers = {
        "Authorization": f"Bearer {JF_TOKEN}",
        "Content-Type": "application/json",
    }
    url = f"{BASE_URL}/templates"
    resp = requests.get(url, headers=headers)
    resp.raise_for_status()
    return resp.json()["items"]


class TemplateCLI:
    def __init__(self, templates):
        self.templates = templates
        self.template_names = [t["name"] for t in templates]
        self.name_to_template = {t["name"]: t for t in templates}
        readline.set_completer(self.completer)
        # Use the whole line for completion (no delimiters)
        readline.set_completer_delims("")
        # Explicitly bind tab to completion (macOS compatibility)
        readline.parse_and_bind("tab: complete")
        readline.parse_and_bind("bind ^I rl_complete")

    def completer(self, text, state):
        options = [
            name
            for name in self.template_names
            if name.lower().startswith(text.lower())
        ]
        if state < len(options):
            return options[state]
        return None

    def pretty_print_template(self, template):
        table = Table(title=f"Template: {template['name']}")
        table.add_column("Field", style="cyan", no_wrap=True)
        table.add_column("Value", style="magenta")
        for key in [
            "id",
            "category",
            "description",
            "created_by",
            "created_at",
            "updated_by",
            "updated_at",
            "version",
            "is_custom",
            "data_source_type",
        ]:
            table.add_row(key, str(template.get(key, "")))
        table.add_row(
            "parameters", json.dumps(template.get("parameters", []), indent=2)
        )
        rego = template.get("rego", "")
        table.add_row("rego", rego[:100] + ("..." if len(rego) > 100 else ""))
        rprint(table)

    def run(self):
        print("Type a template name (Tab for completion, Ctrl+C to exit):")
        while True:
            try:
                name = input("> ").strip()
                if not name:
                    continue
                if name.lower() in ("clean", "clear"):
                    os.system("clear")
                    continue
                template = self.name_to_template.get(name)
                if template:
                    self.pretty_print_template(template)
                    print(
                        "Press Ctrl-R to view the full rego, "
                        "or Enter to continue."
                    )
                    # Wait for Ctrl-R or Enter
                    while True:
                        import sys
                        import termios
                        import tty

                        fd = sys.stdin.fileno()
                        old_settings = termios.tcgetattr(fd)
                        try:
                            tty.setraw(fd)
                            ch = sys.stdin.read(1)
                            if ch == "\r" or ch == "\n":
                                print()
                                break
                            elif ch == "\x12":  # Ctrl-R
                                from rich.syntax import Syntax

                                rego_code = template.get("rego", "")

                                syntax = Syntax(
                                    rego_code,
                                    "rego",
                                    theme="monokai",
                                    line_numbers=True,
                                    word_wrap=False,
                                )
                                rprint(syntax)
                                print("\nPress Enter to continue.")
                                # Wait for Enter to continue
                                while True:
                                    ch2 = sys.stdin.read(1)
                                    if ch2 == "\r" or ch2 == "\n":
                                        print()
                                        break
                                break
                        finally:
                            termios.tcsetattr(
                                fd, termios.TCSADRAIN, old_settings
                            )
                else:
                    print("Template not found. Try again.")
            except (KeyboardInterrupt, EOFError):
                print("\nExiting.")
                break


if __name__ == "__main__":
    try:
        templates = fetch_templates()
    except Exception as e:
        print(f"Failed to fetch templates: {e}")
        exit(1)
    cli = TemplateCLI(templates)
    cli.run()
