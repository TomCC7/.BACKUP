#!/bin/bash
function json_append {
	cat <<< $(jq "$1" "$2") > "$2"
}

# getting sudo privelege
if [[ "$UID" -ne 0 ]]; then
	echo "Asking for sudo privelege..."
	exec sudo "$0" "$@"
	exit 0
fi

# defining vars
BACK_DIR=backup # backup directory
DIR=$(pwd) # root dir

if [[ "$1" == "-r" ]];
then
  echo "Recreate backup directory?"
  read ANS
  if [[ $ANS == 'y' ]];
  then rm -r ./$BACK_DIR
  fi 
fi

if ! [[ -f config.json ]] || [[ $(jq .user config.json) == 'null' ]];
then
  # asking for user name
  echo "Your User name?"
  read USER_NAME 
	# creating config.json
	sudo -u USER_NAME touch config.json
	# if empty, write the root object
	if [[ $(cat config.json) == '' ]];
	then
		echo "{}" > config.json
		json_append ".back_dir=\"$BACK_DIR\"" config.json
	fi	

	json_append ".user=\"$USER_NAME\"" config.json
else
  USER_NAME=$(jq .user config.json|tr -d '"')
fi
	
HOME=/home/$USER_NAME
# finding files...
FILE_NUM=$(cat $DIR/list.txt|wc -l)
echo "Found $FILE_NUM files in list!"

mkdir -p $BACK_DIR # making backup directory

for FILE in $(cat $DIR/list.txt);
do
	echo "linking $FILE..."
	FILE=$(echo $FILE | sed "s?~?$HOME?")
	mkdir -p $DIR/$BACK_DIR$( dirname $FILE)
	ln $FILE $DIR/backup$FILE
done
