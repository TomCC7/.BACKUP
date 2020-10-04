#!/bin/bash
# getting sudo privelege
if [[ "$UID" -ne 0 ]]; then
	echo "Asking for sudo privelege..."
	exec sudo "$0" "$@"
	exit 0
fi

if ! [[ -f config.json ]];
then
	echo "repo not initialized, running init.sh..."
	exec sudo ./sh/init.sh
	exit 0
fi
BACK_DIR=$(jq .back_dir config.json|tr -d '"') # backup directory
DIR=$(pwd) # root dir
HOME=/home/$(jq .user config.json|tr -d '"')

for FILE in $(cat $DIR/list.txt);
do
	echo "recovering $FILE..."
	FILE=$(echo $FILE | sed "s?~?$HOME?")
	# if file already exists, back it up
	if [[ -f $FILE ]];
	then
		echo "$FILE exists, move it to $FILE.old..."
		mv -f $FILE $FILE.old
	fi
	ln $DIR/$BACK_DIR$FILE $FILE
done
echo "done"
