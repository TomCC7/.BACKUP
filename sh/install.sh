#!/bin/bash
if [[ "$UID" -ne 0 ]];
then
  exec sudo $0 $@
  exit 0
fi
# installing dependencies
apt install jq
