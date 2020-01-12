CLASS_COMPONENT=''
FIRST_LETTER_COMPONENT=''
declare -a COMPONENTS
AUX=''
FOLDERS_TO_SEARCH_COMPONENTS=$1
for FOLDER_TO_SEARCH_IMPORTS; do true; done
LS=$(ls -R $FOLDERS_TO_SEARCH_COMPONENTS | awk '/:$/&&f{s=$0;f=0} /:$/&&!f{sub(/:$/,"");s=$0;f=1;next} NF&&f{ print s"/"$0 }')
QNTY_COMP_UNUSED=0
AUX_QNTY=0

sleep 10 &
PID=$!
i=1
sp="/-\|"
echo -n ' '
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
done

getClassComponents() {
  for i in $LS; do
    F_NAME=$i
    if test -f "${F_NAME}"
    then
      CLASS_COMPONENT=$(sudo cat ${F_NAME} | grep -oP '(?<=class).*?(Component)' | awk '{ print $1 }')
      FIRST_LETTER_COMPONENT="$(echo $CLASS_COMPONENT | head -c 1)"
      [[ "$FIRST_LETTER_COMPONENT" =~ [A-Z] ]] && COMPONENTS+=($CLASS_COMPONENT)
    fi
    AUX=${COMPONENTS[@]}
  done
}

searchImports() {
  GREP_RECURSIVE_RESULT=''
  for i in ${COMPONENTS[@]}
  do
    GREP_RECURSIVE_RESULT=$(grep -r -oP '(?<=import).*?('$i')' $FOLDER_TO_SEARCH_IMPORTS)
    [[ -z "$GREP_RECURSIVE_RESULT" ]] && echo -e "\e[39m$i -> \e[33mUNUSED COMPONENT" && ((QNTY_COMP_UNUSED++))
    AUX_QNTY=$QNTY_COMP_UNUSED
  done
}

finalChapter() {
  if [ $QNTY_COMP_UNUSED -eq 0 ]
  then
    echo -e "\e[32mYou don't have unused components :) \e[39m"
  else
   echo -e "\e[33m$QNTY_COMP_UNUSED unused components :/ \e[39m"
  fi 
}

getClassComponents && searchImports && finalChapter