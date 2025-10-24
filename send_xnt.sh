#!/bin/bash

# X1 Blockchain XNT Donation Script
# This script sends 1 XNT to each burner address listed in the CSV file

set -e

# Configuration
SOURCE_CSV="exported_burns_db.csv"
RPC_URL="https://rpc.mainnet.x1.xyz"
WALLET_PATH="$HOME/.config/solana/id.json"
AMOUNT="1"  # 1 XNT to send to each address

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if source CSV file exists
if [ ! -f "$SOURCE_CSV" ]; then
    echo -e "${RED}Error: Source CSV file '$SOURCE_CSV' not found!${NC}"
    exit 1
fi

# Check if wallet exists
if [ ! -f "$WALLET_PATH" ]; then
    echo -e "${RED}Error: Wallet file '$WALLET_PATH' not found!${NC}"
    exit 1
fi

# Create donated directory if it doesn't exist
DONATED_DIR="donated"
if [ ! -d "$DONATED_DIR" ]; then
    echo -e "${BLUE}Creating directory: $DONATED_DIR/${NC}"
    mkdir -p "$DONATED_DIR"
fi

# Create timestamped working CSV file in donated directory
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BASENAME=$(basename "$SOURCE_CSV" .csv)
WORKING_CSV="${DONATED_DIR}/${BASENAME}_${TIMESTAMP}.csv"

echo -e "${BLUE}Creating working copy: $WORKING_CSV${NC}"
cp "$SOURCE_CSV" "$WORKING_CSV"
echo ""

# Set Solana CLI to use X1 RPC
echo -e "${YELLOW}Setting Solana RPC URL to: $RPC_URL${NC}"
solana config set --url "$RPC_URL"

# Get wallet balance
echo -e "${YELLOW}Checking wallet balance...${NC}"
BALANCE=$(solana balance "$WALLET_PATH" 2>/dev/null || echo "Error")
echo -e "${GREEN}Wallet balance: $BALANCE${NC}"
echo ""

# Create a temporary file for the updated CSV
TMP_FILE="${WORKING_CSV}.tmp"

# Counter for statistics
TOTAL=0
SUCCESS=0
FAILED=0
SKIPPED=0

# Read CSV file line by line
echo -e "${YELLOW}Starting XNT distribution...${NC}"
echo ""

# Process the CSV file
while IFS=',' read -r burner total_amount x1_tx || [ -n "$burner" ]; do
    # Remove quotes from fields
    burner=$(echo "$burner" | tr -d '"')
    total_amount=$(echo "$total_amount" | tr -d '"')
    x1_tx=$(echo "$x1_tx" | tr -d '"' | tr -d '\r' | tr -d '\n')
    
    # Skip header line
    if [ "$burner" = "burner" ]; then
        echo "\"burner\",\"total_amount\",\"x1_tx\"" > "$TMP_FILE"
        continue
    fi
    
    # Skip if already processed (has transaction ID)
    if [ ! -z "$x1_tx" ]; then
        echo -e "${YELLOW}Skipping $burner - already processed (tx: $x1_tx)${NC}"
        echo "\"$burner\",\"$total_amount\",\"$x1_tx\"" >> "$TMP_FILE"
        ((SKIPPED++))
        continue
    fi
    
    ((TOTAL++))
    
    echo -e "${YELLOW}[$TOTAL] Processing: $burner (burned: $total_amount)${NC}"
    
    # Send 1 XNT to the address
    # Note: On Solana, we need to use 'sol' as the unit. Adjust if XNT is a custom token
    TX_SIGNATURE=$(solana transfer --from "$WALLET_PATH" "$burner" "$AMOUNT" --allow-unfunded-recipient --fee-payer "$WALLET_PATH" 2>&1)
    
    # Check if transfer was successful
    if echo "$TX_SIGNATURE" | grep -q "Signature:"; then
        # Extract the actual signature
        SIGNATURE=$(echo "$TX_SIGNATURE" | grep "Signature:" | awk '{print $2}')
        echo -e "${GREEN}✓ Success! Transaction: $SIGNATURE${NC}"
        echo "\"$burner\",\"$total_amount\",\"$SIGNATURE\"" >> "$TMP_FILE"
        ((SUCCESS++))
    else
        echo -e "${RED}✗ Failed to send to $burner${NC}"
        echo -e "${RED}Error: $TX_SIGNATURE${NC}"
        # Write back without transaction ID
        echo "\"$burner\",\"$total_amount\",\"\"" >> "$TMP_FILE"
        ((FAILED++))
    fi
    
    echo ""
    
    # Small delay to avoid overwhelming the RPC
    sleep 1
    
done < "$WORKING_CSV"

# Replace working file with updated one
mv "$TMP_FILE" "$WORKING_CSV"

# Print summary
echo ""
echo "========================================"
echo -e "${GREEN}Distribution Summary:${NC}"
echo "----------------------------------------"
echo "Total addresses processed: $TOTAL"
echo -e "${GREEN}Successful: $SUCCESS${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "${YELLOW}Skipped (already processed): $SKIPPED${NC}"
echo "----------------------------------------"
echo -e "${BLUE}Results saved to: $WORKING_CSV${NC}"
echo "========================================"
echo ""
echo -e "${GREEN}Transaction records have been saved!${NC}"
echo -e "${YELLOW}Note: Source file '$SOURCE_CSV' remains unchanged.${NC}"

