#!/usr/bin/env bats

load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

@test 'Test used component' {
  run echo "$(./findead.sh -m tests/{imports,components} | grep -o 'No unused components found')"
  assert_output "No unused components found"
}

@test 'Test unused component(without imports)' {
  run echo "$(./findead.sh tests/components | grep -o '14 possible dead components :/')"
  assert_output "14 possible dead components :/"
}

@test 'Test unused component(commented imports)' {
  run echo "$(./findead.sh -m tests/{imports_commented,components} | grep -o '14 possible dead components :/')"
  assert_output "14 possible dead components :/"
}

@test 'Test error: paths must precede expression' {
  run bash -c "cd tests/components/ && ../../findead.sh | grep -o 'paths must precede expression'"
  assert_failure
}

@test 'Test --version predicate' {
  PACKAGE_VERSION=$(cat ./package.json | grep '"version": .*,' | awk '{ print $2 }' | cut -d '"' -f 2)
  run ./findead.sh --version
  assert_output "findead@$PACKAGE_VERSION"
}

@test 'Test -v predicate' {
  PACKAGE_VERSION=$(cat ./package.json | grep '"version": .*,' | awk '{ print $2 }' | cut -d '"' -f 2)
  run ./findead.sh -v
  assert_output "findead@$PACKAGE_VERSION"
}

@test 'Test --help predicate' {
  run ./findead.sh --help
  assert_line --partial 'findead -h | --help'
}

@test 'Test -h predicate' {
  run ./findead.sh -h
  assert_line --partial 'findead -h | --help'
}

@test 'Test -r predicate' {
  run echo "$(./findead.sh -r tests | grep -o 'No unused components found')"
  assert_output 'No unused components found'
}

@test 'Test multiples predicates' {
  run echo "$(./findead.sh -mr tests/{imports_commented,components} | grep -o '14 possible dead components :/')"
  assert_output '14 possible dead components :/'
}

@test 'Test specific comands' {
  run wc -c < ./tests/components/A.js
  assert_line --partial '108'
}

@test 'Test ignored type files' {
  run bash -c "cd tests/ignored_types/ && ../../findead.sh | grep -o '1 browsed files in'"
  assert_output '1 browsed files in'
}

@test 'Test ignored paths' {
  run bash -c "cd tests/ignored_paths/ && ../../findead.sh | grep -o '1 browsed files in'"
  assert_output '1 browsed files in'
}