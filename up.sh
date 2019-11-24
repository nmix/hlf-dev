#!/bin/bash

docker-compose up -d -V --force-recreate orderer peer cli couchdb
