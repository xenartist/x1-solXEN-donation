#!/bin/bash

# List and summarize all execution history files

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

DONATED_DIR="donated"

echo -e "${CYAN}======================================${NC}"
echo -e "${CYAN}  Execution History Summary${NC}"
echo -e "${CYAN}======================================${NC}"
echo ""

# Check source file
SOURCE_FILE="exported_burns_db.csv"
if [ -f "$SOURCE_FILE" ]; then
    TOTAL=$(grep -v "^\"burner\"" "$SOURCE_FILE" | wc -l | tr -d ' ')
    echo -e "${YELLOW}Source File: $SOURCE_FILE${NC}"
    echo -e "  Total addresses: ${BLUE}$TOTAL${NC}"
    echo ""
else
    echo -e "${RED}Source file not found!${NC}"
    echo ""
fi

# Check if donated directory exists
if [ ! -d "$DONATED_DIR" ]; then
    echo -e "${YELLOW}Donated directory does not exist yet.${NC}"
    echo -e "${YELLOW}Run ./send_xnt.sh to create the first execution record.${NC}"
    echo ""
    exit 0
fi

# List timestamped files in donated directory
HISTORY_FILES=($(ls -1t "$DONATED_DIR"/exported_burns_db_*.csv 2>/dev/null))

if [ ${#HISTORY_FILES[@]} -eq 0 ]; then
    echo -e "${YELLOW}No execution history files found.${NC}"
    echo -e "${YELLOW}Run ./send_xnt.sh to create the first execution record.${NC}"
    echo ""
    exit 0
fi

echo -e "${YELLOW}Execution History (most recent first):${NC}"
echo "========================================"
echo ""

for file in "${HISTORY_FILES[@]}"; do
    # Extract timestamp from filename
    TIMESTAMP=$(echo "$file" | sed 's/exported_burns_db_\(.*\)\.csv/\1/')
    YEAR=${TIMESTAMP:0:4}
    MONTH=${TIMESTAMP:4:2}
    DAY=${TIMESTAMP:6:2}
    HOUR=${TIMESTAMP:9:2}
    MINUTE=${TIMESTAMP:11:2}
    SECOND=${TIMESTAMP:13:2}
    DATE_STR="$YEAR-$MONTH-$DAY $HOUR:$MINUTE:$SECOND"
    
    # Count addresses
    TOTAL=$(grep -v "^\"burner\"" "$file" | wc -l | tr -d ' ')
    
    # Count processed (has tx hash)
    PROCESSED=$(grep -v "^\"burner\"" "$file" | awk -F',' '$3 != "" && $3 != "\r" && $3 != "\"\""' | wc -l | tr -d ' ')
    
    # Calculate pending
    PENDING=$((TOTAL - PROCESSED))
    
    echo -e "${BLUE}File: $file${NC}"
    echo -e "  Date: ${CYAN}$DATE_STR${NC}"
    echo -e "  Total addresses: $TOTAL"
    echo -e "  ${GREEN}Processed: $PROCESSED${NC}"
    echo -e "  ${YELLOW}Pending: $PENDING${NC}"
    
    # File size
    SIZE=$(ls -lh "$file" | awk '{print $5}')
    echo -e "  Size: $SIZE"
    echo ""
done

echo "========================================"
echo -e "${YELLOW}Total history files: ${BLUE}${#HISTORY_FILES[@]}${NC}"
echo -e "${YELLOW}Location: ${BLUE}${DONATED_DIR}/${NC}"
echo ""
echo -e "${YELLOW}To view details of a specific file:${NC}"
echo -e "${BLUE}./dry_run.sh donated/<filename>${NC}"
echo ""

