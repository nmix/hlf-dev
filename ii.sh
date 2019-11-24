#!/bin/bash

# Installation and instantiate chaincode
#
# Usage:
# ./ii.sh [-nCC_NAME] [-s] [ARGS]
#
# Options:
# -n   chaincode name
# -u   username from config/users (default is root)
# -s   skip installation. Typically used when instantiation fails.
#
# Examples:
# ./ii.sh init a 100 b 300
# ./ii.sh init "john k" 100 "marry s" 300
#
# Install and instantiate tokenv5 changecode from parent directory
# (no parameters are passed to the constructor)
# ./ii.sh -ntokenv5

. ./_funcs.sh
parse_opts "$@"
# --- remove optional arguments
shift $((OPTIND-1))

if [ -z $SKIP_INSTALL ]
then
  echo "Installing chaincode <$CC_NAME>"
  echo "------------------------------------------------------------"

  docker-compose exec cli peer chaincode install \
    -n "$CC_NAME" \
    -v 0 \
    -p chaincodedev/chaincode/$CC_NAME
fi

CC_ARGS=$(argue "$@")

echo
echo "Instantiate chaincode <$CC_NAME> with args: $CC_ARGS"
echo "------------------------------------------------------------"

docker-compose exec cli peer chaincode instantiate \
  -n "$CC_NAME" \
  -v 0 -c "$CC_ARGS" \
  -C myc
