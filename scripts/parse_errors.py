#!/usr/bin/env python3

import os
import sys
from pathlib import Path


def main():
    log_file = (
        Path(sys.argv[1]).expanduser()
        if len(sys.argv) > 1
        else Path.home() / "devops-task3/logs/app.log"
    )

    # Read the simulated API token from the environment.
    api_token = os.environ.get("SIMULATED_API_TOKEN")

    if not api_token:
        print("ERROR: SIMULATED_API_TOKEN is not set.")
        return 1

    # Do not print or expose the token.
    try:
        log_content = log_file.read_text(encoding="utf-8")
        error_count = log_content.count("ERROR")

        print(f"Log file: {log_file}")
        print(f"Number of ERROR occurrences: {error_count}")
        return 0

    except FileNotFoundError:
        print(f"ERROR: Log file not found: {log_file}")
        return 1

    except PermissionError:
        print(f"ERROR: Permission denied reading: {log_file}")
        return 1

    except OSError as exc:
        print(f"ERROR: Could not read log file: {exc}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
