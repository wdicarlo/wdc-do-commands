#!/usr/bin/env bash
[ -z $WDC_DO_COMMANDS_DIR ] && echo "Undefined WDC_DO_COMMANDS_DIR." && exit
cntfile="$(echo $WDC_DO_COMMANDS_DIR/do_cmd_counts.csv)"
idxfile="$(echo $WDC_DO_COMMANDS_DIR/do_cmd_index.csv)"
idx="d${1}";shift
[ "$idx" == "d-h" ] && do-cmd-index -t "$1" && exit
[ "$idx" == "d-c" ] && cat "$cntfile" |sort -t';' -n -r -k2| column -s ';' -t && exit
cmdname=$(cat "$idxfile"|grep "^${idx};"|cut -d';' -f2|tr -d ' ')
cmd="$cmdname $@"
[ -t 0 ] && echo "> $cmd"
[ $(grep -c "$cmdname" "$cntfile" 2>/dev/null) -eq 0 ] && echo "${cmdname};0" >> "$cntfile"
eval "sed -i 's/^\(${cmdname}\);\([0-9]\+\)/echo \"\1;\$((\2+1))\"/ge' $cntfile"
eval "$cmd"
