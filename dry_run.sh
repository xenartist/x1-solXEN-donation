#!/bin/bash

# X1 Blockchain XNT Donation Script - DRY RUN MODE
# This script simulates the donation process WITHOUT actually sending tokens

set -e

# Configuration
DEFAULT_CSV="exported_burns_db.csv"
DONATED_DIR="donated"
RPC_URL="https://rpc.testnet.x1.xyz"
WALLET_PATH="$HOME/.config/solana/id.json"
AMOUNT="1"  # 1 XNT to send to each address

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Allow user to specify CSV file, or use default
CSV_FILE="${1:-$DEFAULT_CSV}"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}    DRY RUN MODE - NO TOKENS SENT    ${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Check if CSV file exists
if [ ! -f "$CSV_FILE" ]; then
    echo -e "${RED}Error: CSV file '$CSV_FILE' not found!${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  $0                                    # Check source file"
    echo -e "  $0 donated/<csv_file>                 # Check specific file"
    echo ""
    echo -e "${YELLOW}Available timestamped files in donated/:${NC}"
    if [ -d "$DONATED_DIR" ]; then
        ls -1t "$DONATED_DIR"/exported_burns_db_*.csv 2>/dev/null | head -5 || echo "  (none found)"
    else
        echo "  (donated directory not found)"
    fi
    exit 1
fi

echo -e "${YELLOW}Analyzing file: $CSV_FILE${NC}"
echo ""

# Check if wallet exists
if [ ! -f "$WALLET_PATH" ]; then
    echo -e "${RED}Error: Wallet file '$WALLET_PATH' not found!${NC}"
    exit 1
fi

# Get wallet address
echo -e "${YELLOW}RPC URL: $RPC_URL${NC}"
WALLET_ADDRESS=$(solana-keygen pubkey "$WALLET_PATH" 2>/dev/null || echo "Error reading wallet")
echo -e "${YELLOW}Wallet Address: $WALLET_ADDRESS${NC}"
echo -e "${YELLOW}Amount per address: $AMOUNT XNT${NC}"
echo ""

# Counter for statistics
TOTAL=0
TO_PROCESS=0
ALREADY_DONE=0

# Read CSV file line by line
echo -e "${YELLOW}Analyzing addresses...${NC}"
echo ""

while IFS=',' read -r burner total_amount x1_tx || [ -n "$burner" ]; do
    # Remove quotes from fields
    burner=$(echo "$burner" | tr -d '"')
    total_amount=$(echo "$total_amount" | tr -d '"')
    x1_tx=$(echo "$x1_tx" | tr -d '"' | tr -d '\r' | tr -d '\n')
    
    # Skip header line
    if [ "$burner" = "burner" ]; then
        continue
    fi
    
    ((TOTAL++))
    
    # Check if already processed
    if [ ! -z "$x1_tx" ]; then
        echo -e "${GREEN}[$TOTAL] ✓ $burner (burned: $total_amount) - ALREADY PROCESSED${NC}"
        echo -e "    ${GREEN}Transaction: $x1_tx${NC}"
        ((ALREADY_DONE++))
    else
        echo -e "${YELLOW}[$TOTAL] ○ $burner (burned: $total_amount) - WILL BE PROCESSED${NC}"
        ((TO_PROCESS++))
    fi
    
done < "$CSV_FILE"

# Print summary
echo ""
echo "========================================"
echo -e "${BLUE}DRY RUN SUMMARY:${NC}"
echo "----------------------------------------"
echo -e "Total addresses in CSV: ${BLUE}$TOTAL${NC}"
echo -e "${GREEN}Already processed: $ALREADY_DONE${NC}"
echo -e "${YELLOW}To be processed: $TO_PROCESS${NC}"
echo "----------------------------------------"
echo -e "Total XNT needed: ${BLUE}$TO_PROCESS XNT${NC}"
echo -e "Estimated fees: ${BLUE}~$(echo "$TO_PROCESS * 0.000005" | bc) XNT${NC}"
echo -e "Total estimated cost: ${BLUE}~$(echo "$TO_PROCESS * 1.000005" | bc) XNT${NC}"
echo "========================================"
echo ""

if [ $TO_PROCESS -eq 0 ]; then
    echo -e "${GREEN}All addresses have already been processed!${NC}"
    if [ "$CSV_FILE" = "$DEFAULT_CSV" ]; then
        echo -e "${YELLOW}This is the source file. Consider checking previous runs:${NC}"
        echo -e "${BLUE}./dry_run.sh donated/exported_burns_db_YYYYMMDD_HHMMSS.csv${NC}"
    fi
else
    echo -e "${YELLOW}To proceed with actual distribution, run:${NC}"
    echo -e "${BLUE}./send_xnt.sh${NC}"
    echo ""
    echo -e "${YELLOW}This will create a new timestamped file in donated/ directory.${NC}"
fi

echo ""

