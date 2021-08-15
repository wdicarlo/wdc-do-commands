#!/usr/bin/env bash
[ -z $WDC_DO_COMMANDS_DIR ] && echo "Undefined WDC_DO_COMMANDS_DIR." && exit
cntfile="$(echo $WDC_DO_COMMANDS_DIR/do_cmd_counts.csv)"
[ ! -f "$cntfile" ] && touch "$cntfile"
idxfile="$(echo $WDC_DO_COMMANDS_DIR/do_cmd_index.csv)"
[ ! -f "$idxfile" ] && touch "$idxfile"
idx="d${1}";shift
[ "$idx" == "d-h" ] && 
  echo "d [-h] [-s [<patt>]] [-c] <cmd> <params>" && 
  echo "d -h          : help" &&
  echo "d -s [<patt>] : list shortcuts filtered by <patt>" &&
  echo "d -c          : list usage counter" && exit
[ "$idx" == "d-s" ] && do-cmd-index -t "$1" && exit
[ "$idx" == "d-c" ] && cat "$cntfile" | while IFS=';' read -r cmd count; do echo "$(do-cmd-index ";$cmd$"|cut -d';' -f1);$cmd;$count"; done |sort -t';' -n -r -k3| column -s ';' -t && exit
[ "${idx:0:2}" == "d-" ] && echo "Wrong option. Use d -h to get availble options." && exit 
cmdname=$(cat "$idxfile"|grep "^${idx};"|cut -d';' -f2|tr -d ' ')
[ "$cmdname" == "" ] && echo "No command found for $idx" && exit
[ $(grep -c "$cmdname" "$cntfile") -eq 0 ] && read -p "First use of the command (${cmdname})! Continue? (y/[n]) " ans && [ ! "$ans" == "y" ] && exit 
cmd="$cmdname" && for par in "$@"; do cmd="$cmd \"${par}\""; done
[ -t 0 ] && echo "> $cmd"
[ $(grep -c "$cmdname" "$cntfile" 2>/dev/null) -eq 0 ] && echo "${cmdname};0" >> "$cntfile"
eval "sed -i 's/^\(${cmdname}\);\([0-9]\+\)/echo \"\1;\$((\2+1))\"/ge' $cntfile"
eval "$cmd"
