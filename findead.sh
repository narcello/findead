CLASS_COMPONENT=''
FIRST_LETTER_COMPONENT=''
declare -a COMPONENTS
AUX=''
FOLDERS_TO_SEARCH_COMPONENTS=$1
for FOLDER_TO_SEARCH_IMPORTS; do true; done
LS=$(find $FOLDERS_TO_SEARCH_COMPONENTS -type f \( -name "*.js" -o -name "*.jsx" \))
QNTY_COMP_UNUSED=0
AUX_QNTY=0

sleep 10 &
PID=$!
i=1
sp="/-\|"
echo -n ' '
while [ -d /proc/$PID ]; do
  printf "\b${sp:i++%${#sp}:1}"
done

F_NAME=''
getClassComponents() {
  CLASS_COMPONENT=$(sudo cat ${F_NAME} | grep -oP '(?<=class).*?(Component)' | awk '{ print $1 }')
  COMPONENTS+=($CLASS_COMPONENT)
  AUX=${COMPONENTS[@]}
}

getFunctionComponents() {
  IS_REACT_FILE=$(sudo cat ${F_NAME} | grep -oP '(?<=import).*?(React)')
  if [ ! -z "$IS_REACT_FILE" ]; then
    FUNCTIONS=$(sudo cat ${F_NAME} | grep -oP '(?<=function ).*?(?=\()')
    for FUNCTION in $FUNCTIONS; do
      FIRST_LETTER_FUNCTION_COMPONENT="$(echo "$FUNCTION" | head -c 1)"
      [[ "$FIRST_LETTER_FUNCTION_COMPONENT" =~ [A-Z] ]] && COMPONENTS+=($FUNCTION)
    done
  fi
  AUX=${COMPONENTS[@]}
}

getComponents() {
  for i in $LS; do
    F_NAME=$i
    getClassComponents
    getFunctionComponents
  done
}

searchImports() {
  GREP_RECURSIVE_RESULT=''
  for i in ${COMPONENTS[@]}; do
    GREP_RECURSIVE_RESULT=$(grep -r -oP '(?<=import).*?('$i')' $FOLDER_TO_SEARCH_IMPORTS)
    [[ -z "$GREP_RECURSIVE_RESULT" ]] && echo -e "\e[39m$i -> \e[33mUNUSED COMPONENT" && ((QNTY_COMP_UNUSED++))
    AUX_QNTY=$QNTY_COMP_UNUSED
  done
}

finalChapter() {
  if [ $QNTY_COMP_UNUSED -eq 0 ]; then
    echo -e "\e[32mYou don't have unused components :) \e[39m"
  else
    echo -e "\e[33m$QNTY_COMP_UNUSED unused components :/ \e[39m"
  fi
}

getComponents && searchImports && finalChapter
