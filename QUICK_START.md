# Quick Start Guide

## First Time Usage

```bash
# 1. View addresses to be processed (no tokens will be sent)
./dry_run.sh

# 2. Check wallet balance
solana config set --url https://rpc.testnet.x1.xyz
solana balance ~/.config/solana/id.json

# 3. Execute sending (will create a new timestamped file)
./send_xnt.sh
```

## Common Commands

### View All Execution History
```bash
./list_history.sh
```

### View Details of a Specific History File
```bash
./dry_run.sh donated/exported_burns_db_20251025_092229.csv
```

### Run Again (After Adding New Addresses)
```bash
# Edit exported_burns_db.csv to add new addresses
./dry_run.sh              # Preview
./send_xnt.sh             # Execute
```

## File Description

- **`exported_burns_db.csv`** - Original address list (manually maintained, not modified by script)
- **`donated/`** - Directory containing execution history files
- **`donated/exported_burns_db_YYYYMMDD_HHMMSS.csv`** - Execution records (auto-generated)

## Switch to Mainnet

Edit `send_xnt.sh`, modify line 10:

```bash
RPC_URL="https://rpc.mainnet.x1.xyz"  # Change to mainnet address
```

## Important Notes

⚠️ **Original file `exported_burns_db.csv` is NEVER modified by the script**

✅ Each run of `send_xnt.sh` creates a new timestamped file in `donated/` directory

✅ Can run the script multiple times, each with complete history records

✅ Already processed addresses are automatically skipped (resume support)

✅ All execution history is organized in the `donated/` directory
