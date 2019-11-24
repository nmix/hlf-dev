#!/bin/bash
set -e

# Launch one or more chain codes
# In the case of several chain codes, assembly and launch are performed in parallel
# 
# Usages:
# ./run-cc.sh [opts] [chaincode1 chaincode2 ...]
#
# Options:
#   -p    path to the source code. Used if the sources are not located in the directory
#
# Examples:
#
# Launch the built-in chaincode
# ./run-cc.sh
#
# Run the code from the parent directory
# (the script is supposed to be executed from the subdirectory of the chaincode project)
# ./run-cc.sh sacc
#
# Parallel running chain codes from directories tokenv5 and caller
# ./run-cc.sh tokenv5 caller

while getopts ":p:" opt
do
  case $opt in
    p)
      CC_SOURCE_FILES=$OPTARG
      ;;
  esac
done

shift $((OPTIND-1))

if [ $# == 0 ]
then
  # --- if the script is called without arguments, restart it
  #     with the token.go chaincode from the project root
  $0 -ptoken.go token
elif [ $# == 1 ]
then
  # --- if one argument is passed, we assume that the sources are located
  #     in the parent directory
  CC_NAME=$1
  if [ -z "$CC_SOURCE_FILES" ]
  then
    CC_SOURCE_FILES=../*.go
  fi

  echo "Building chaincode <$CC_NAME>"
  echo "Source file(s): $CC_SOURCE_FILES"
  echo "------------------------------------------------------------"

  # --- create and clean the directory for the project
  mkdir -p chaincode/$CC_NAME
  rm -rf chaincode/$CC_NAME/*

  # --- create a chaincode binary
  go build -o chaincode/$CC_NAME/$CC_NAME $CC_SOURCE_FILES

  # --- copy the source to a temporary directory
  cp $CC_SOURCE_FILES chaincode/$CC_NAME

  # --- run chaincode
  CORE_CHAINCODE_ID_NAME=$CC_NAME:0 CORE_PEER_TLS_ENABLED=false \
    ./chaincode/$CC_NAME/$CC_NAME -peer.address localhost:7052
else
  # --- if several arguments are passed, then we assume that the first argument
  #     is the chain code from the parent directory, and the rest from the directory
  FIRST_CC_NAME="'$0 $1'"
  OTHER_CC_NAME=()
  for i in "${@:2}"
  do
    PROJECT_PATH=$i
    CC_NAME=$(basename $PROJECT_PATH)
    OTHER_CC_NAME+=("'$0 -p$GOPATH/src/$PROJECT_PATH/*.go $CC_NAME' ")
  done
  echo "parallel --lb ::: $FIRST_CC_NAME ${OTHER_CC_NAME[*]}" | bash -
fi
