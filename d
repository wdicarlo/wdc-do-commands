#!/usr/bin/env bash
[ -z $WDC_DO_COMMANDS_DIR ] && echo "Undefined WDC_DO_COMMANDS_DIR." && exit
idx="d${1}";shift
[ "$idx" == "d-h" ] && do-cmd-index -t "$1" && exit
cmdname=$(cat "$WDC_DO_COMMANDS_DIR/do_cmd.index"|grep "^${idx}:"|cut -d':' -f2|tr -d ' ')
cmd="$cmdname $@"
[ -t 0 ] && echo "> $cmd"
[ $(grep -c "$cmdname" "$WDC_DO_COMMANDS_DIR/do_cmd.csv" 2>/dev/null) -eq 0 ] && echo "${cmdname};0" >> "$WDC_DO_COMMANDS_DIR/do_cmd.csv"
eval "sed -i 's/^\(${cmdname}\);\([0-9]\+\)/echo \"\1;\$((\2+1))\"/ge' $WDC_DO_COMMANDS_DIR/do_cmd.csv"
eval "$cmd"
