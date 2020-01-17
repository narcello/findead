#!/usr/bin/env bats

load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

@test 'Test used component' {
  run echo "$( ./findead.sh ./tests/components ./tests/imports | perl -nle'print if m{No unused components found}')"
  assert_output "No unused components found"
}

@test 'Test unused component' {
  run echo "$( ./findead.sh ./tests/components | perl -nle'print if m{10 possible dead components :/}')"
  assert_output "10 possible dead components :/"
}