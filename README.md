# X1 SolXEN Donation Project

This project is used to batch send XNT token rewards to SolXEN burner addresses on the X1 blockchain (a Solana fork).

## Core Features

- ✅ **History Preservation**: Each run creates a new timestamped file, original file remains unchanged
- ✅ **Batch Sending**: Send XNT to multiple addresses at once
- ✅ **Automatic Recording**: Transaction hashes automatically written to CSV file
- ✅ **Resume Support**: Already processed addresses are automatically skipped
- ✅ **Dry-run Mode**: Preview and validate before sending
- ✅ **New Address Support**: Automatically handles brand new addresses on X1

## Project Files

- **`send_xnt.sh`** - Main sending script
  - Creates a timestamped CSV copy in `donated/` directory
  - Sends XNT to all addresses
  - Records transaction hashes in the new copy
  
- **`dry_run.sh`** - Test script (no tokens sent)
  - Preview addresses to be processed
  - Calculate required XNT amount
  - Can view historical record files in `donated/` directory

- **`list_history.sh`** - History viewing tool
  - List all execution history files from `donated/` directory
  - Display statistics for each execution
  - Sort by time in descending order
  
- **`exported_burns_db.csv`** - Original address list (remains unchanged)

- **`donated/`** - Directory containing execution history files
  - `donated/exported_burns_db_YYYYMMDD_HHMMSS.csv` - Timestamped execution records (auto-generated)

## Quick Start

### 1. Run Dry Run Test (Recommended)

Check original file status:

```bash
./dry_run.sh
```

Check a specific history file:

```bash
./dry_run.sh donated/exported_burns_db_20251025_092229.csv
```

### 2. Execute Actual Sending

```bash
./send_xnt.sh
```

The script will:
1. Create `donated/` directory if it doesn't exist
2. Copy `exported_burns_db.csv` as `donated/exported_burns_db_YYYYMMDD_HHMMSS.csv`
3. Process and update transaction records in the new file
4. Keep the original file unchanged, can run multiple times

### 3. View Execution History

View summary of all history records:

```bash
./list_history.sh
```

View detailed status of a specific history record:

```bash
./dry_run.sh donated/exported_burns_db_20251025_092229.csv
```

## Workflow

```
Original file: exported_burns_db.csv (never changes)
    ↓
First run: donated/exported_burns_db_20251025_092229.csv (with transaction records)
    ↓
Second run: donated/exported_burns_db_20251025_153045.csv (new transaction records)
    ↓
Third run: donated/exported_burns_db_20251026_100530.csv (more new records)
```

Each timestamped file in the `donated/` directory contains complete execution records, convenient for tracking and auditing.

## Configuration

Script default configuration (can be modified in the script):

```bash
SOURCE_CSV="exported_burns_db.csv"            # Original CSV file
RPC_URL="https://rpc.testnet.x1.xyz"          # X1 testnet RPC
WALLET_PATH="$HOME/.config/solana/id.json"    # Sender wallet
AMOUNT="1"                                     # Amount to send per address
```

### Switch to Mainnet

Edit `send_xnt.sh` and modify:

```bash
RPC_URL="https://rpc.x1.xyz"  # Or other mainnet RPC address
```

## CSV File Format

```csv
"burner","total_amount","x1_tx"
"address1","burned_amount","transaction_hash"
"address2","burned_amount",""
```

- `burner`: Recipient address
- `total_amount`: Amount of tokens burned (for reference)
- `x1_tx`: Transaction hash (filled by script)

## Use Cases

### Scenario 1: First Sending

```bash
./dry_run.sh              # Preview original file
./send_xnt.sh             # Execute sending
# Generates: donated/exported_burns_db_20251025_092229.csv
```

### Scenario 2: Send Again After Adding New Addresses

```bash
# Add new addresses to exported_burns_db.csv
./dry_run.sh              # Check which addresses will be processed
./send_xnt.sh             # Execute sending
# Generates: donated/exported_burns_db_20251025_153045.csv
```

### Scenario 3: View History Records

```bash
# List all execution records with summary
./list_history.sh

# View details of a specific record
./dry_run.sh donated/exported_burns_db_20251025_092229.csv
```

## System Requirements

- ✅ Solana CLI installed
- ✅ Wallet file: `~/.config/solana/id.json`
- ✅ Sufficient XNT balance in wallet

## Security Tips

1. **Testnet First**: Uses testnet by default, thoroughly test before switching to mainnet
2. **Wallet Security**: Protect your `~/.config/solana/id.json` file
3. **Balance Check**: Confirm sufficient balance before running
4. **History Review**: Regularly check history files to ensure transactions are correct

## Troubleshooting

### Check Wallet Balance

```bash
solana config set --url https://rpc.testnet.x1.xyz
solana balance ~/.config/solana/id.json
```

### Test RPC Connection

```bash
solana cluster-version --url https://rpc.testnet.x1.xyz
```

### View Recent Execution Records

```bash
./list_history.sh
```

## License

See LICENSE file
