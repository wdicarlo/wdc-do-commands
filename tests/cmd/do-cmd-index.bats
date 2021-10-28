#!/usr/bin/env bats

setup() {
  echo "Test setup"
}

teardown() {
  echo "Test teardown"
}
@test "no args -> prints list of abbreviations and commands" {
  run do-cmd-index 
  [ $status -eq 0 ]
  [ "${#lines[@]}" -gt 10 ]
  [ "$(expr "$output" : ".*dc;do-cmd.*")" -ne 0 ]
}

@test "-u update the abbreviations index" {
  run do-cmd-index -u
  [ $status -eq 0 ]
  [ "${#lines[@]}" -gt 10 ]
  [ "${lines[0]}" == "Predefined: db -> do-bookmark" ]
}

@test "one arg -> used to filter abbreviations index" {
  run do-cmd-index do-cmd-find
  [ $status -eq 0 ]
  [ "${#lines[@]}" -eq 1 ]
  [ "${lines[0]}" == "dcf;do-cmd-find" ]
}
