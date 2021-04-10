#!/bin/bash

## HELPERS ##
function json_append {
  cat <<< $(jq "$1" "$2") > "$2"
}

# @Brief link with check first
# @Var $1 src
# @Var $2 dir
function ln_check() {
  # check linked file existence
  [[ -f "$2" ]] && return
  # check file is symbolic link
  FILE_SRC="$1"
  if [[ "$(readlink "$FILE_SRC")" != "" ]];
  then
    FILE_SRC="$(readlink "$FILE_SRC")"
    # relative
    if [[ "${FILE_SRC:0:1}" != "/" ]];
    then
      FILE_SRC="$(dirname "$1")/$FILE_SRC"
    fi
    echo "linking "$1" -> "$FILE_SRC""
  fi
  ln "$FILE_SRC" "$2"
}

## FUNCS ##
# @Brief synchronize directory
# @Var $1 directory to sync
function sync_dir() {
  LS=/usr/bin/ls
  mkdir -p "$DIR/backup$1"
  $LS -A "$1" | while read FILE
  do
    FILE="$1/$FILE" # absolute path
    if [[ -d "$FILE" ]]; then
      sync_dir "$FILE" 
    else
      ln_check "$FILE" "$DIR/backup$FILE"
    fi
  done
}

# getting sudo privelege
if [[ "$UID" -ne 0 ]]; then
  echo "Asking for sudo privelege..."
  export USR=$USER
  sudo -E "$0" "$@"
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
  then rm -rf ./$BACK_DIR/*
  fi 
fi

if ! [[ -f config.json ]] || [[ $(jq .user config.json) == 'null' ]];
then
  # creating config.json
  sudo -u $USR touch config.json
  # if empty, write the root object
  if [[ $(cat config.json) == '' ]];
  then
    echo "{}" > config.json
    json_append ".back_dir=\"$BACK_DIR\"" config.json
  fi
  json_append ".user=\"$USR\"" config.json
fi

# finding files...
FILE_NUM=$(cat $DIR/list.txt|wc -l)
echo "Found $FILE_NUM files in list!"

mkdir -p $BACK_DIR # making backup directory

for FILE in $(cat $DIR/list.txt);
do
  FILE=$(echo "$FILE" | sed "s?~?$HOME?")
  if [ -d "$FILE" ]; then
    # echo "Directory currently not supported!"
    sync_dir "$FILE"
  elif [ -f $FILE ]; then
    mkdir -p "$DIR/$BACK_DIR$(dirname $FILE)"
    ln_check "$FILE" "$DIR/backup$FILE"
  else
    echo "Error: Path $FILE does not exist on your computer!"
    continue
  fi
  echo "$FILE linked"
done
chown -R $USR:$USR $DIR/backup/* # change ownership
echo "All FILE LINKED"
