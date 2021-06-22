#!/usr/bin/env bash
idx="d${1}";shift
[ "$idx" == "d-h" ] && do-cmd-index -t "$1" && exit
cmd=$(cat ~/wbin/do_cmd.index|grep "^${idx}:"|cut -d':' -f2)
cmd="$cmd $@"
[ -t 0 ] && echo "> $cmd"
eval "$cmd"
