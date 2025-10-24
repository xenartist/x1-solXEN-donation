# Donated Directory

This directory contains execution history files from the XNT donation script.

## Purpose

All timestamped CSV files with transaction records are automatically saved here when you run `send_xnt.sh`.

## File Naming Convention

```
exported_burns_db_YYYYMMDD_HHMMSS.csv
```

Where:
- `YYYYMMDD` = Date (Year, Month, Day)
- `HHMMSS` = Time (Hour, Minute, Second)

## Example

```
exported_burns_db_20251025_092229.csv  # Execution on Oct 25, 2025 at 09:22:29
exported_burns_db_20251025_153045.csv  # Execution on Oct 25, 2025 at 15:30:45
```

## Viewing History

To view all execution history:
```bash
../list_history.sh
```

To view details of a specific file:
```bash
../dry_run.sh donated/exported_burns_db_20251025_092229.csv
```

## Note

These files are created automatically by the script. Do not manually edit them unless necessary.

