#!/usr/bin/env bats

setup() {
  echo "Test setup"
}

teardown() {
  echo "Test teardown"
}
@test "no args -> prints help" {
  run do-cmd-find
  printf "'%s'\n" "${lines[0]}"
  [ "${lines[0]}" == "Usage: do-cmd-find [-h] [-q] [-f] [-c] [-a] [-o] [-t] [-r <root>] <string>" ]
}


@test "-h and --help print help" {
  run do-cmd-find -h
  printf "'%s'\n" "${lines[0]}"
  [ $status -eq 0 ]
  [ "${#lines[@]}" -gt 3 ]
}

@test "find filename" {
  run do-cmd-find -f -r "$WDC_DO_COMMANDS_DIR/cmd/" find
  printf "'%s'\n" "${lines[1]}"
  [ $status -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[1]}" == "do-cmd-find" ]
}


@test "find in howto files" {
  run do-cmd-find -t "find word under cursor"
  [ "${#lines[@]}" -eq 2 ]
  [ "$(echo ${lines[1]}|sed 's/^\(.*\):[0-9]\+:.*$/\1/')" == "howto/howto_vim.otl" ]
}

