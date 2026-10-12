# Automated Log Backup System

## Project Overview

This project implements an automated log backup system using Bash on Linux. It compresses application log files into timestamped `.tar.gz` archives, verifies archive integrity, and records execution results.

The project demonstrates Linux automation, cron scheduling, file system management, Git version control, and secrets hygiene.

## Objectives

- Automate log file archiving using Bash.
- Schedule unattended backups using the Linux cron daemon.
- Verify the integrity of generated archives.
- Record backup successes and failures.
- Use Git to track source code changes.
- Protect configuration and sensitive information using environment variables and `.gitignore`.

## Technologies Used

- Bash
- Linux
- `tar` and `gzip`
- Cron
- Git
- `curl` for optional HTTP webhook notifications

## Project Structure

```text
devops-task3/
├── .gitignore
├── README.md
├── scripts/
│   └── backup_logs.sh
├── logs/       # Local test files; excluded from Git
├── backups/    # Generated archives; excluded from Git
└── reports/    # Runtime logs; excluded from Git
```

## Prerequisites

- A Linux system such as Ubuntu or Debian
- Bash
- Git
- Cron
- `tar`, `gzip`, and `flock`
- `curl` for the optional webhook feature

## Configuration

The script supports configuration through environment variables and an optional private configuration file:

`~/.config/task3/backup.env`

Supported variables:

- `SOURCE_DIR`: Directory containing log files.
- `BACKUP_DIR`: Destination for compressed archives.
- `LOG_FILE`: Path to the backup execution log.
- `WEBHOOK_URL`: Optional HTTP notification endpoint.

Keep private configuration outside the Git repository. Never commit real credentials, access tokens, or private webhook URLs.

## Usage

Make the script executable:

```bash
chmod 700 scripts/backup_logs.sh
```

Run the backup manually:

```bash
./scripts/backup_logs.sh
```

List generated archives:

```bash
ls -lh backups/
```

Inspect the execution log:

```bash
cat reports/backup.log
```

Verify an archive:

```bash
tar -tzf backups/ARCHIVE_NAME.tar.gz
```

Replace `ARCHIVE_NAME.tar.gz` with an actual generated filename.

## Cron Scheduling

To run the script every day at 2:00 AM, add the following entry to the user's crontab, replacing `/home/raph` if your home directory differs:

```cron
0 2 * * * /bin/bash /home/raph/devops-task3/scripts/backup_logs.sh
```

View the scheduled jobs:

```bash
crontab -l
```

Cron uses the system's configured time zone.

## Security Measures

- `.gitignore` excludes generated backups, local logs, and private configuration files.
- The script uses restrictive file permissions.
- Configuration can be supplied through environment variables.
- A lock file helps prevent overlapping backup executions.
- Archive integrity is checked before the final archive is published.

## Testing

The project should be tested by running the script manually, verifying the archive contents, checking the execution log, and confirming automatic execution through cron.

Document actual test results and include screenshots when submitting the project.

## Optional Enhancement

The script supports an HTTP POST notification when `WEBHOOK_URL` is configured. The webhook endpoint should be kept private and should never be hardcoded into the script.

## Author

Raphael Coleman

## Internship

Elevvo Cloud & DevOps Internship — Task 3: Automated Infrastructure Scripting & Secrets Hygiene
