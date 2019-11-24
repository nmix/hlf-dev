#!/bin/bash

# launch a container for handling chaincode events
#
# Usage:
# ./listener.sh [CC_NAME EVENT_NAME]
#
# Run without parameters - default events are listened
# CC_NAME=token EVENT_NAME=InvokeTokenEvent
# ./listener.sh
#
# Handling TokenValueChanged Tokenv5 Event
# ./listener.sh tokenv5 TokenValueChanged

CC_NAME=$1
EVENT_NAME=$2

if [ -z "$CC_NAME" ]
then
  CC_NAME=token
fi

if [ -z "$EVENT_NAME" ]
then
  EVENT_NAME=InvokeTokenEvent
fi

CC_NAME=$CC_NAME EVENT_NAME=$EVENT_NAME docker-compose \
  up --force-recreate -V listener

