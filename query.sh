#!/bin/bash

# Read request to chaincode
#
# Usage:
# ./query.sh [-nCC_NAME] [-uUSER] [ARGS]
# Options:
# -n   chaincode name
# -u   username from config/users (default is root)
# Examples:
# ./query.sh
# ./query.sh -ntokenv5 request "J Doe"
# ./query.sh -ntokenv5 -umary request "J Doe"

. ./_funcs.sh

parse_opts "$@"
# --- remove optional arguments
shift $((OPTIND-1))

docker-compose exec -e CORE_PEER_MSPCONFIGPATH=${MSPCONFIGPATH} cli \
  peer chaincode query \
  -n "$CC_NAME" \
  -c "$(argue "$@")" \
  -C myc
