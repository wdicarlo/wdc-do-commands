wdc-do-commands
===============

Personal set of Linux commands

## Introduction ##

* why - I have collected/developed all commands which helps me to improve my workflow.
* goals - To store my learned experience and make it, if possible, executable.
* overview - the commands/files have been grouped by scope/context and by types of operation. Note that:
  * commands starts either with do- or do_
  * text files have an extension to characterize the type of file

There are the following different types of commands/files:
  * do-<scope>[-<action>] - do commands about a <scope> that can be executed directly
  * do_<scope>[_<action>] - do commands about a <scope> that need to be sourced
  * do-pipe-<scope>[-<action>] - do commands about a <scope> to me used in a pipeline
  * howto_<tool>.otl - text files containing tips and tricks about the <tool>

The most important scopes are:
  * cmd - commands that help to manage the all commands
  * find - commands to help find files
  * git - commands to simplify the use of git tool
  * arc - commands to deal with archives
  * ...

Execute the following do command to list all scopes with more than one command
```bash
./do-find-folders -n 1
```

## Getting started ##
### Download ###
Download the repository with
```bash
git clone https://github.com/wdicarlo/wdc-do-commands
```
### Setup .bashrc ###
Execute the following setup command
```bash
./sys/do-sys-install-bash-customization
```
which will add the following lines into the ~/.bashrc file
```bash
[ -f "$WDC_DO_COMMANDS_DIR/do_bash_customization" ] && source "$WDC_DO_COMMANDS_DIR/do_bash_customization"
```
Source .bashrc to activate the customizations
```bash
source ~/.bsahrc
```

### Setup commands modules ###
Edit the do_cmd_groups.csv file to define which groups/scopes of commands you prefer to activate.

Execute the following command to generate the symbolic links for the activated commands
```bash
do-cmd-groups-slinks
```

### Create a project ###
Create the new project mydemo with the following command
```bash
do-project-creation mydemo
```
The command will create a folder with the specified name of the project under the folder specified in the environment variable PROJECTS.
In such folder a file named .bash_env will be created. Such file get sourced when the project is activated or cd into such folder.
At the end of the project setup, it get activated by cd into the folder.

### Customize env  ###
Edit the .bash_env file to customize the environment of the project when it get activated.
The file can contain commands to set environment variables, source other scripts and, eventually, print some information.

### Switch project ###
It is possible to switch/activate another project by using the following command
```bash
do-project-activation myotherdemo
```

## Command help ##
Some help can be obtained in the following ways:
* command options - by executing the command with the -h option
* command code - by reading the code of the command
* howto - by using the do-howto-print command. For example ```do-howto-print git tag``` will print all reference to tag present in the file howto_git.otl
* do-man - by using the do-man command. For example ```do-man find``` will print details and examples of the linux find command

## Project management ##
A project can be managed with the following commands:
* do-project-creation and do-project-activation - to create and activate it
* do-bookmark and do-cd-bookmark - to jump into tagged folder of the project
* do-vim -t <task> - to edit files of the project related to the specified task

### Project setup script templates ###
TBD

### Folder bookmarks ###
TBD

### do-vim command ###
TBD

## d commands ##
In order to reduce the keys to type to specify a command a d command has been created.
The d command translate command name shortcuts into the command to be executed.
For example the following command correspond to execute the ```do-find-string mystringtosearch```
```bash
d fs mystringtosearch
```
The shortcuts are stored in the file do_cmd_index.csv generated using the command do-cmd-index. Such command generate the shortcut by considering the first letter after each '-' sign.
The following are some examples of such shortcuts:
```
dad;do-ascii-dump
da;do-ansible
daef;do-arc-extract-files
daf;do-arc-files
dafo;do-arc-folder
dagc;do-aks-get-credentials
dalf;do-arc-list-folders
dar;do-arduino
das;do-asciinema
dba;do-backup
```
Note that in some case it is considered more than one character after the last '-' sign if there is a shortcut clash with different commands.
For example 'do-backup' is not mapped to 'db' because such shortcut is used to map another command. The list can be obtained with the following command
```bash
$ d -s b # to list all shortcuts containing the string db
dba    do-backup
dbd    do-backup-documents
db     do-bookmark
dbf    do-backup-file
dbfo   do-backup-folder
dbm    do-backup-mydocuments
dbsf   do-backup-sav-files
dglc   do-gdb-list-callstack
dpglc  do-pipe-gdb-list-callstack
dpwdb  do-pipe-words-delimited-by
dscd   do-sql-create-db
```
Some shortcuts can be forzed to be associated to preferred commands editing the following file
```bash
$ cat do_cmd_index_def.csv
dsd;do-sec-decrypt
dhe;do-howto-edit
dgs;do-git-status
dgcu;do-git-commit-unstaged
dgpul;do-git-pull
dgpus;do-git-push
dpa;do-project-activation
dpc;do-project-creation
dcb;do-cd-bookmark
db;do-bookmark
```

## howto commands ##
The following command create the howto_do.otl which will contain tips and tricks for the do commands
```bash
$ do-howto-create do "WDC Do Commands" "Personal set of Linux commands"
WDC Do Commands
	Personal set of Linux commands
```
The following command will update the do howto file
```bash
$ do-howto-update do "Find do commands containg the prettyprint string" "d cf prettyprint"
WDC Do Commands
	Personal set of Linux commands
Find do commands containg the prettyprint string
	d cf prettyprint
```
Indeed using the mentioned command
```bash
$ d cf prettyprint
> do-cmd-find prettyprint
> git ls-files | grep "^do[-_].*\\|/do[-_].*" | xargs -I@ \grep --color -Hn prettyprint @
do-files-overview:44:        cat "$file" | do-pipe-table-prettyprinted | head -25
```
Note that:
* "d cf" correspond to do-cmd-find
* "> do-cmd-find ..." is the proof that "d cf" has been mapped to "do-cmd-find"
* "> git ls-files | ..." is the command executed by the do-cmd-find command

To find within the howto of the do commands it is possible to use the do-howto-find command. For example
```bash
$ d hp do find
> do-howto-print do find
3:Find do commands containg the prettyprint string
4-	d cf prettyprint
```
The list of available howto can be obtained with the following command
```bash
$ do-howto-list 
airflow
ansible
asciidoc
avro
az
bash
bash_scripting
c
curl
debian
do
docker
gdb
git
github
gitlab
gpg
gstreamer
helm
ip
jq
k8s
linux
lua
make
mongodb
pandashells
redis
s3cmd
smb
sops
sqlite
svn
terraform
vim
yq
```
or more shortly with ```d hl```


## Advanced setup ##
### Bash completions ###
TBD

### Commands groups ###
TBD

### Commands management ###
TBD

## TODO ##
[ ] improve howto print command
[ ] harmonize the commands
[ ] apply shellcheck
[ ] add bat tests

## Contribution ##
type of contributions
commands
howto
harmonization

## Acknowledgements ##
TBD 

## License ##
TBD
