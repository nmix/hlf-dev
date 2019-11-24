#!/bin/bash

# Write request to the chaincode
#
# Usage:
# ./invoke.sh [-nCC_NAME] [ARGS]
# Options:
# -n   chaincode name
# -u   username from config/users (default is root)
# Examples:
# ./invoke.sh
# ./invoke.sh -ntokenv5 transfer Mary "J Doe" 1000
# ./invoke.sh -nrichq ExecuteRichQuery '{"selector":{"txnDate": "2009-12-12T00:00:00Z"}}'

. ./_funcs.sh
parse_opts "$@"
# --- remove optional arguments
shift $((OPTIND-1))

docker-compose exec cli peer chaincode invoke \
  -n "$CC_NAME" \
  -o orderer:7050 \
  -c "$(argue "$@")" \
  -C myc
