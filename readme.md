# Automated Backup System

## A. Project Overview

This project provides an automated backup script that creates compressed backups of important folders, verifies them, and manages old backups to save storage space. It ensures that your files are safely archived and that only the most relevant backups are kept.

### What the Script Does

* Takes a folder as input and creates a `.tar.gz` compressed backup file.
* Generates a checksum to ensure that the backup is valid and not corrupted.
* Skips unwanted folders like `.git`, `node_modules`, and temporary cache folders.
* Automatically deletes older backups while keeping recent daily, weekly, and monthly backups.
* Logs every action to a `backup.log` file.
* Supports a **dry-run mode** to preview actions without making changes.

### Why It Is Useful

Manually backing up files can be time‑consuming and easy to forget. This script automates the entire backup process, ensures data safety, and avoids wasted storage due to too many old backups.

---

## B. How to Use It

### 1. Installation

1. Place the script file `backup.sh` and `backup.conf` in the same folder.
2. Make the script executable:

```
chmod +x backup.sh
```

3. (Optional) Edit `backup.conf` to customize:

```
BACKUP_DESTINATION=/home/backups
EXCLUDE_PATTERNS=".git,node_modules,.cache"
DAILY_KEEP=7
WEEKLY_KEEP=4
MONTHLY_KEEP=3
```

### 2. Basic Usage Examples

| Purpose                        | Command Example                                                                        |
| ------------------------------ | -------------------------------------------------------------------------------------- |
| Run backup normally            | `./backup.sh /path/to/folder`                                                |
| Test without changing anything | `./backup.sh --dry-run /path/to/folder`                                      |
| List existing backups          | `./backup.sh --list`                                                         |
| Restore from a backup          | `./backup.sh --restore backup-YYYY-MM-DD-HHMM.tar.gz --to /path/to/restore/` |

### 3. Command Options

| Option                         | Meaning                                                 |
| ------------------------------ | ------------------------------------------------------- |
| `--dry-run`                    | Shows what the script *would* do without making changes |
| `--list`                       | Displays all available backups                          |
| `--restore <file> --to <path>` | Extracts backup contents into a destination folder      |

---

## C. How It Works

### Backup Naming Format

```
backup-YYYY-MM-DD-HHMM.tar.gz
```

Example:

```
backup-2024-11-03-1430.tar.gz
```

<img width="1188" height="424" alt="image" src="https://github.com/user-attachments/assets/1f134445-03e7-47c3-b83f-9a13bbcf4e10" />

### Excluding Unnecessary Files

The script reads patterns from `EXCLUDE_PATTERNS` and passes them to `tar`.
Common skipped folders: `.git`, `node_modules`, `.cache`

### Checksum Verification

* After backup: A checksum (SHA256 by default) is generated.
* The checksum is stored in a `.md5` file.
* During verification, the script recomputes and compares the two checksums.

### Backup Rotation Rules

The script keeps:

* The **last 7 daily** backups
* The **last 4 weekly** backups (one backup per week)
* The **last 3 monthly** backups (one backup per month)

Backups older than these are deleted.

### Folder Structure

```
backups/
 ├── backup-2025-02-01-1200.tar.gz
 ├── backup-2025-01-28-1200.tar.gz.md5
 └── ...
```

---

## D. Design Decisions

### Why This Approach?

* **Tar and gzip** provide fast and widely supported compression.
* **SHA256 checksums** are reliable for detecting corruption.
* **Rotation by date** ensures predictable backup retention.

### Challenges Faced

| Challenge                                   | Solution                                  |
| ------------------------------------------- | ----------------------------------------- |
| Preventing two backup runs at the same time | Added a lock file `/tmp/backup.lock`      |
| Avoiding unnecessary data in backups        | User‑configurable exclude patterns        |
| Saving storage space                        | Implemented daily/weekly/monthly rotation |

---

## E. Testing

### Testing Steps

1. Ran the script in `--dry-run` mode to confirm actions.
2. Created real backups and verified checksum validation.
3. Deleted and restored sample test folders.

### Example Output

```
[2025-02-12 14:30:15] INFO: Starting backup of /home/user/Documents
[2025-02-12 14:30:45] SUCCESS: Backup created: backup-2025-02-12-1430.tar.gz
[2025-02-12 14:30:50] SUCCESS: Checksum verified successfully
```

---

## F. Known Limitations

| Limitation                         | Explanation                                         |
| ---------------------------------- | --------------------------------------------------- |
| Incremental backups not supported  | Script currently backs up full folder every time    |
| Email notifications simulated only | Real email sending requires configuring mail server |
| Date processing uses GNU date      | On macOS, may require installing `coreutils`        |

### Future Improvements

* Add **incremental backup support** to save time and storage.
* Add real **email alerts** for success/failure.
* Add **GUI or web interface** for easier usage.

---
G. Conclusion

This automated backup system helps ensure your important files are safely archived and managed. It simplifies the entire backup process, from creating compressed backups to verifying them and cleaning up old files. While there are areas to improve, the script provides a strong foundation for reliable and efficient backups.
