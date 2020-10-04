#!/bin/bash
# getting sudo privelege
if [[ "$UID" -ne 0 ]]; then
  echo "Asking for sudo privelege..."
  exec sudo "$0" "$@"
  exit 0
fi

HOME=/home/$(jq .user config.json|tr -d '"')
for FILE in $(cat list.txt);
do
  echo "removing $FILE.old..."
  FILE=$(echo $FILE | sed "s?~?$HOME?")
  rm $FILE.old
done
