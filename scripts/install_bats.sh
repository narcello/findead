install_bats() {
  cd bats
  sudo ./install.sh /usr/local
}

clone_bats_repo() {
  cd ~
  EXISTS_BATS_FOLDER=$(ls | grep 'bats')
  [[ -z "$EXISTS_BATS_FOLDER" ]] && git clone https://github.com/sstephenson/bats.git
  install_bats
}

check_bats_on_environment() {
  EXISTS_BATS_ON_ENVIRONMENT=$(whereis bats | grep 'bats: .*')
  [[ -z "$EXISTS_BATS_ON_ENVIRONMENT" ]] && clone_bats_repo
}

check_bats_on_environment
