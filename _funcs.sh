#!/bin/bash

# Common script options analyzer
# Values for the following variables are defined here:
# CC_NAME
# CC_USER
# MSPCONFIGPATH
# SKIP_INSTALL
function parse_opts {
  # --- analyze options
  while getopts "n:u:s" opt
  do
    case "${opt}" in
      n)
        CC_NAME=$OPTARG
        ;;
      u)
        CC_USER=$OPTARG
        ;;
      s)
        SKIP_INSTALL=1
        ;;
    esac
  done

  # --- remove optional arguments
  shift $((OPTIND-1))

  # --- set the name of the default chaincode
  if [ -z $CC_NAME ];
  then
    CC_NAME=token
  fi

  # --- set the default user name
  if [ -z $CC_USER ];
  then
    CC_USER=root
  fi
  MSPCONFIGPATH=/etc/hyperledger/users/${CC_USER}/msp
}

# Combining multiple values through a separator
# @see https://zaiste.net/how_to_join_elements_of_an_array_in_bash/
# @note the function is not suitable if there are spaces in the array elements
function join { 
  local IFS="$1"
  shift
  echo "$*"
}

# cast a string of arguments of the form
# init a 10 b 20 "c d" 30 "{'a': {'b': '123'}}'
# to the view string
# {"Args": ["init","a","10","b","20","c d","30","{'a': {'b': '123'}}"]}
function argue {
  args_array=( "$@" )
  # --- wrap each element in quotes and concatenation into a string separated
  #     by commas
  args_str=""
  for i in ${!args_array[@]}
  do
    args_str+="\"${args_array[$i]}\","
  done
  # --- remove the last comma if the line is not empty
  if [ ! -z "$args_str" ] ; then args_str=${args_str%?} ; fi
  # --- wrap in Args
  echo "{\"Args\": [$args_str]}"
}
