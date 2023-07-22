#!/usr/bin/env bash

# Exit if anythign fails
set -eo pipefail

# Set environment variables
if [ -f .env ]; then
    set -a; source .env; set +a
fi

# Change directory to project root
SCRIPT_PATH="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd "$SCRIPT_PATH/.." || exit

# Variables
while getopts p: flag
do
    case "${flag}" in
        p) PROFILE=${OPTARG};;
    esac
done

echo "Running tests with profile: $PROFILE"

# Compile scripts
npx tsc --p tsconfig.json

if [[ "$PROFILE" = "default" ]]; then
    TOKEN_TEST=false forge test
fi

if [[ "$PROFILE" = "token" ]]; then
    # Check if the file exists
    if [ -e "reports/TOKENS_REPORT.md" ]; then
        # If the file exists, delete it
        rm "reports/TOKENS_REPORT.md"
    fi 

    # ATTENTION: Uses FFI
    TOKEN_TEST=true forge test --ffi
fi