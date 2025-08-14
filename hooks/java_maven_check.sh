#!/bin/bash
# Validate Java compilation and Maven pom.xml

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}🔍 Running Java & Maven checks...${NC}"

# Check Java files
JAVA_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.java$')
if [[ -n "$JAVA_FILES" ]]; then
    for file in $JAVA_FILES; do
        if ! javac "$file" 2>/dev/null; then
            echo -e "${RED}❌ Java compilation failed for $file${NC}"
            exit 1
        fi
    done
fi

# Validate Maven pom.xml
if [[ -f "pom.xml" ]]; then
    mvn validate > /dev/null
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}❌ Maven validation failed${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Java & Maven checks passed.${NC}"
exit 0