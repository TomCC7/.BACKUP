# Backup
Some shell scripts helps you backing up your files

## Usage

### First use

```bash
# fork one copy to your directory
# **you may want to change the visibility...**
git clone https://github.com/{Your name}/.backup
cd .backup # make sure you are at this directory
# add the files you want to backup in lists.
# example:
#	~/.zshrc
#	~/.zsh_history
#	~/.bashrc
#	~/.ssh/id_rsa.pub
#	/usr/bin/daemon-start
#	~/.vimrc
./sh/init.sh # run the initialize file
```

### Reinit

```bash
./sh/init.sh -r # this will delete the whole backup directory completely and create it again, be careful if you already have something deleted
```

### Recover

```bash
./sh/recover.sh
```

## Change Log

### Oct 5 2020

- Add init.sh, recover.sh
- list.txt now supports using `~` as home directory

### Apr 3 2021
- Now supports adding directory to sync
- Don't need to give user name now

### Apr 11 2021
- fix bug: can't process file with space
- file linked won't be linked again
