CLASS_COMPONENT=''
FIRST_LETTER_COMPONENT=''
declare -a COMPONENTS
AUX_ARRAY_COMPONENTS=''
FOLDERS_TO_SEARCH_COMPONENTS=$1
for FOLDER_TO_SEARCH_IMPORTS; do true; done
FIND_RETURN=$(find $FOLDERS_TO_SEARCH_COMPONENTS -type f \( -name "*.js" -o -name "*.jsx" \))
COUNTER_UNUSED_COMPONENTS=0
AUX_COUNTER=0

echo 'Findead are looking for components...' &&
  FILE_PATH=''
getClassComponents() {
  CLASS_COMPONENT=$(cat ${FILE_PATH} | grep -o '(?<=class).*?(Component)' | awk '{ print $1 }')
  USED_IN_SAME_FILE=$(perl -nle'print if m{<'$CLASS_COMPONENT'}' ${FILE_PATH})
  if [ ! -z "$CLASS_COMPONENT" ]; then
    [[ -z "$USED_IN_SAME_FILE" ]] && COMPONENTS+=($CLASS_COMPONENT)
  fi
  AUX_ARRAY_COMPONENTS=${COMPONENTS[@]}
}

CURRENT_FUNCTIONS=''
checkFunctions() {
  for FUNCTION in $CURRENT_FUNCTIONS; do
    if [[ ! $FUNCTION =~ ^(\[|\]|\{|\})$ ]]; then
      FIRST_LETTER_FUNCTION_COMPONENT="$(echo "$FUNCTION" | head -c 1)"
      USED_IN_SAME_FILE=$(grep -o "<$FUNCTION" ${FILE_PATH})
      [[ "$FIRST_LETTER_FUNCTION_COMPONENT" =~ [A-Z] ]] &&
        [[ -z "$USED_IN_SAME_FILE" ]] && COMPONENTS+=($FUNCTION)
    fi
    AUX_ARRAY_COMPONENTS=${COMPONENTS[@]}
  done
}

getES5FunctionComponents() {
  CURRENT_FUNCTIONS=$(cat ${FILE_PATH} | grep -o '(?<=function ).*?(?=\()')
  checkFunctions
}

getES6FunctionComponents() {
  CURRENT_FUNCTIONS=$(cat ${FILE_PATH} | grep -o '(?<=const ).*?(?= \= \(.*\) \=>)' | awk '{ print $1 }')
  checkFunctions
}

getFunctionComponents() {
  IS_REACT_FILE=$(cat ${FILE_PATH} | grep -o '(?<=import).*?(React)')
  if [ ! -z "$IS_REACT_FILE" ]; then
    getES5FunctionComponents
    getES6FunctionComponents
  fi
}

getComponents() {
  for i in $FIND_RETURN; do
    FILE_PATH=$i
    getClassComponents
    getFunctionComponents
  done
}

searchImports() {
  GREP_RECURSIVE_RESULT=''
  for COMPONENT in ${COMPONENTS[@]}; do
    GREP_RECURSIVE_RESULT=$(find ${FOLDER_TO_SEARCH_IMPORTS} -type f -exec cat {} + | perl -nle'print $& while m{(?<=import).*?('$COMPONENT' .*from)}g')
    [[ -z "$GREP_RECURSIVE_RESULT" ]] && echo -e "\e[39m$COMPONENT -> \e[33mUNUSED COMPONENT" && ((COUNTER_UNUSED_COMPONENTS++))
    AUX_COUNTER=$COUNTER_UNUSED_COMPONENTS
  done
}

showResult() {
  if [ $COUNTER_UNUSED_COMPONENTS -eq 0 ]; then
    echo -e "No unused components found"
  else
    echo -e "$COUNTER_UNUSED_COMPONENTS possible dead components :/"
  fi
}

getComponents && searchImports && showResult
