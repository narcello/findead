CLASS_COMPONENT=''
FIRST_LETTER_COMPONENT=''
declare -a COMPONENTS
AUX=''
FOLDERS_TO_SEARCH_COMPONENTS=$1
for FOLDER_TO_SEARCH_IMPORTS; do true; done
LS=$(find $FOLDERS_TO_SEARCH_COMPONENTS -type f \( -name "*.js" -o -name "*.jsx" \))
QNTY_COMP_UNUSED=0
AUX_QNTY=0

sleep 60 &
PID=$!
i=1
sp="/-\|"
echo -n ' '
while [ -d /proc/$PID ]; do
  printf "\b${sp:i++%${#sp}:1}"
  sleep 0.1s
done

F_NAME=''
getClassComponents() {
  CLASS_COMPONENT=$(sudo cat ${F_NAME} | grep -oP '(?<=class).*?(Component)' | awk '{ print $1 }')
  USED_IN_SAME_FILE=$(grep "<${CLASS_COMPONENT}" ${F_NAME})
  if [ ! -z "$CLASS_COMPONENT" ]; then
    [[ -z "$USED_IN_SAME_FILE" ]] && COMPONENTS+=($CLASS_COMPONENT)
  fi
  AUX=${COMPONENTS[@]}
}

CURRENT_FUNCTIONS=''
checkFunctions() {
  for FUNCTION in $CURRENT_FUNCTIONS; do
    FIRST_LETTER_FUNCTION_COMPONENT="$(echo "$FUNCTION" | head -c 1)"
    [[ "$FIRST_LETTER_FUNCTION_COMPONENT" =~ [A-Z] ]] &&
      USED_IN_SAME_FILE=$(grep "<${FUNCTION}" ${F_NAME}) &&
      [[ -z "$USED_IN_SAME_FILE" ]] && COMPONENTS+=($FUNCTION)
    AUX=${COMPONENTS[@]}
  done
}

getES5FunctionComponents() {
  CURRENT_FUNCTIONS=$(sudo cat ${F_NAME} | grep -oP '(?<=function ).*?(?=\()')
  checkFunctions
}

getES6FunctionComponents() {
  CURRENT_FUNCTIONS=$(sudo cat ${F_NAME} | grep -oP '(?<=const ).*?(?=\()' | awk '{ print $1 }')
  checkFunctions
}

getFunctionComponents() {
  IS_REACT_FILE=$(sudo cat ${F_NAME} | grep -oP '(?<=import).*?(React)')
  if [ ! -z "$IS_REACT_FILE" ]; then
    getES5FunctionComponents
    getES6FunctionComponents
  fi
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
    echo -e "\e[33m$QNTY_COMP_UNUSED possible dead components :/ \e[39m"
  fi
}

getComponents && searchImports && finalChapter
