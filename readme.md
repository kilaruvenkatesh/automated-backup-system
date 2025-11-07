# 🧠 Automated Backup System  
### 👨‍💻 Developed by: Kilaru Venkatesh (RIS00472)

A fully automated **Bash-based backup system** with compression, checksum verification, rotation cleanup, and restore support.  
This project demonstrates advanced shell scripting for real-world DevOps-style automation.

---

## 🚀 Project Overview

The **Automated Backup System** simplifies data protection by automatically creating compressed backups of important files, verifying their integrity, and cleaning up old backups.

It ensures your files are safely archived, easily restorable, and that only the most recent backups are kept — saving both time and storage.

---

## ⚙️ Features

| Feature | Description |
|----------|--------------|
| 🗂️ **Automated Backups** | Creates timestamped folders for every run |
| 📦 **Compression** | Option to create `.tar.gz` archives |
| 🔐 **Checksum Validation** | Generates `.sha256` file for data integrity verification |
| 🧹 **Rotation Cleanup** | Automatically deletes old backups (keeps last 5 by default) |
| 🧱 **Exclusion Support** | Skips unnecessary folders like `.git`, `node_modules`, etc. |
| 🧪 **Dry Run Mode** | Simulate backups without writing data |
| 🧾 **Logging System** | Saves all actions in `backup.log` |
| 🧰 **Restore Mode** | Extracts or copies backups back into a chosen directory |
| 📋 **List Mode** | Displays all existing backups |
| 🕒 **Recent Backup Option** | Backup only files modified in the last ‘X’ days |

---

## 🧩 Project Structure

graded_task_backup_system/
├── backup.sh # Main script
├── backup.conf # Configuration file
├── backup.txt # Output log (for easy viewing)
├── backup.log # Full detailed log
├── data/ # Folder containing files to back up
├── backups/ # Generated backups with timestamps
└── README.md # Project documentation

yaml
Copy code

---

## ⚙️ Configuration (backup.conf)

You can customize default settings by editing `backup.conf`:

```bash
BACKUP_DESTINATION=backups
EXCLUDE_PATTERNS=".git node_modules .cache temp"
DAILY_KEEP=7
WEEKLY_KEEP=4
MONTHLY_KEEP=3
💻 Usage Guide
1️⃣ Give script execute permission
bash
Copy code
chmod +x backup.sh
2️⃣ Run a standard backup
bash
Copy code
./backup.sh
3️⃣ Backup with compression
bash
Copy code
./backup.sh --compress
4️⃣ Dry run (simulate actions)
bash
Copy code
./backup.sh --dry-run
5️⃣ Backup recently changed files
bash
Copy code
./backup.sh --recent 2d
6️⃣ List all backups
bash
Copy code
./backup.sh --list
7️⃣ Restore from backup
bash
Copy code
./backup.sh --restore backups/backup-2025-11-07_22-38-41.tar.gz --to restore_test/
📦 Example Output
yaml
Copy code
[Fri, Nov  7, 2025 10:38:41 PM] 🚀 Starting backup...
[Fri, Nov  7, 2025 10:38:41 PM] 📂 No files specified — defaulting to all files in data/
[Fri, Nov  7, 2025 10:38:41 PM] ✅ Backed up: data/config.yaml
[Fri, Nov  7, 2025 10:38:42 PM] ✅ Backed up: data/k venkatesh(RIS00472)DevOps1.txt
[Fri, Nov  7, 2025 10:38:43 PM] 🔐 Checksum file created: 2025-11-07_22-38-41.sha256
[Fri, Nov  7, 2025 10:38:44 PM] 🎯 Backup process completed successfully.
[Fri, Nov  7, 2025 10:38:44 PM] ✅ Backup saved at: backups/2025-11-07_22-38-41
[Fri, Nov  7, 2025 10:38:44 PM] 📘 Log file: backup.log
🧠 How It Works
Detects files (or defaults to data/)

Creates a timestamped backup folder

Optionally compresses the data

Generates a checksum for integrity

Cleans up old backups automatically

Logs all actions to backup.log and backup.txt

🔐 Backup Integrity (Checksum)
Each backup run creates a .sha256 file:

yaml
Copy code
2025-11-07_22-38-41.sha256
To verify file integrity later:

bash
Copy code
sha256sum -c backups/2025-11-07_22-38-41.sha256
🧪 Testing Process
Test	Description	Result
Dry Run	Previewed without actual file copy	✅ Successful
Compression	Created .tar.gz archive	✅ Passed
Checksum	Verified generated hash	✅ Passed
Restore	Extracted to restore_test folder	✅ Restored Successfully
Rotation	Old backups deleted automatically	✅ Working

⚠️ Known Limitations
Limitation	Description
Incremental backups not supported	Always performs full backups
Email notifications not implemented	Planned feature for next version
Requires GNU utilities (sha256sum, tar)	Default in Linux / WSL / Git Bash

🛠️ Future Improvements
Add incremental backup support

Add email notifications for success/failure

Integrate cron scheduling for daily backups

Build a simple web dashboard for monitoring

📘 License
MIT License © 2025 Kilaru Venkatesh

🌐 Connect
GitHub Repository:
👉 https://github.com/kilaru-venkatesh/automated-backup-system

yaml
Copy code

---
