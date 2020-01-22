#!/usr/bin/env bats

load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

@test 'Test used component' {
  run echo "$( ./findead.sh ./tests/components ./tests/imports | grep 'No unused components found')"
  assert_output "No unused components found"
}

@test 'Test unused component' {
  run echo "$( ./findead.sh ./tests/components | grep 'dead components')"
  assert_output "10 possible dead components :/"
}

@test 'Test --version predicate' {
  PACKAGE_VERSION=$(cat ./package.json | grep '"version": .*,' | awk '{ print $2 }' | cut -d '"' -f 2)
  run echo "$( ./findead.sh --version)"
  assert_output "findead@$PACKAGE_VERSION"
}

@test 'Test -v predicate' {
  PACKAGE_VERSION=$(cat ./package.json | grep '"version": .*,' | awk '{ print $2 }' | cut -d '"' -f 2)
  run echo "$( ./findead.sh -v)"
  assert_output "findead@$PACKAGE_VERSION"
}

@test 'Test --help predicate' {
  run echo "$( ./findead.sh --help)"
  assert_output "
  findead is used for looking for possible unused components(Dead components)

  usage: 
    findead path/to/search/components path/to/find/imports(optional)
    findead -h | --help
    findead -v | --version

  report bugs to: https://github.com/narcello/findead/issues"
}

@test 'Test -h predicate' {
  run echo "$( ./findead.sh -h)"
  assert_output "
  findead is used for looking for possible unused components(Dead components)

  usage: 
    findead path/to/search/components path/to/find/imports(optional)
    findead -h | --help
    findead -v | --version

  report bugs to: https://github.com/narcello/findead/issues"
}