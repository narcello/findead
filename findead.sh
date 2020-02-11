#!/bin/bash

# set -e

CLASS_COMPONENT=''
FIRST_LETTER_COMPONENT=''
declare -a COMPONENTS
AUX_ARRAY_COMPONENTS=''
COUNTER_UNUSED_COMPONENTS=0
AUX_COUNTER=0
FIND_RETURN=''
FIRST_ARGUMENT=$1
PATH_TO_FIND=''
FINDEAD_TIME=''
TIMEFORMAT="%R"
FILE_PATH=''
CURRENT_FUNCTIONS=''
if [ $# -gt 1 ]; then
  MULTIPLE_PATHS=$(echo $FIRST_ARGUMENT | grep '\-.*m')
  RAW=$(echo $FIRST_ARGUMENT | grep '\-.*r')
fi

fileSizeKB() {
  FILE_SIZE_B=$(wc -c <$1)
  [[ ${FILE_SIZE_B} -lt 1024 ]] && echo "${FILE_SIZE_B} Bytes"
  [[ ${FILE_SIZE_B} -gt 1023 ]] && echo "$(echo ${FILE_SIZE_B}/1024 | bc) KB"
}

center() {
  termwidth="$(tput -T xterm cols)"
  padding="$(printf '%0.1s' ={1..500})"
  printf '%*.*s %s %*.*s\n' 0 "$(((termwidth - 2 - ${#1}) / 2))" "$padding" "$1" 0 "$(((termwidth - 1 - ${#1}) / 2))" "$padding"
}

centerResult() {
  termwidth="$(tput -T xterm cols)"
  padding="$(printf '%0.1s' ={1..500})"
  printf "\e[0m%*.*s \e[36m%s\e[0m %*.*s\n" 0 "$(((termwidth - 2 - ${#1}) / 2))" "$padding" "$1" 0 "$(((termwidth - 1 - ${#1}) / 2))" "$padding"
}

searchFiles() {
  FIND_RETURN=$(
    eval $"find $PATH_TO_FIND -type f \( ! -name "*.chunk.*" ! -name "*.bundle.*" -name "*.js" -o -name "*.jsx" \) \
    -not -path '*/node_modules/*' \
    -not -path '*/dist/*' \
    -not -path '*/build/*' \
    -not -path '*/bin/*' \
    -not -path '*/out/*' \
    -not -path '*/output/*' \
    -not -path '*/target/*' \
    -not -path '*/log/*' \
    -not -path '*/logs/*' \
    -not -path '*/test/*' \
    -not -path '*/tests/*' \
    -print"
  )
}

getClassComponents() {
  CLASS_COMPONENT=$(cat ${FILE_PATH} | grep -o "class.*Component" | awk '{ print $2 }')
  USED_IN_SAME_FILE=$(grep -o "<$CLASS_COMPONENT" ${FILE_PATH})
  if [ ! -z "$CLASS_COMPONENT" ]; then
    [[ -z "$USED_IN_SAME_FILE" ]] && COMPONENTS+=("$CLASS_COMPONENT;$FILE_PATH")
  fi
  AUX_ARRAY_COMPONENTS=${COMPONENTS[@]}
}

checkFunctions() {
  for FUNCTION in $CURRENT_FUNCTIONS; do
    if [[ ! $FUNCTION =~ ^(\[|\]|\{|\})$ ]]; then
      FIRST_LETTER_FUNCTION_COMPONENT="$(echo "$FUNCTION" | head -c 1)"
      USED_IN_SAME_FILE=$(grep -o "<$FUNCTION" ${FILE_PATH})
      [[ "$FIRST_LETTER_FUNCTION_COMPONENT" =~ [A-Z] ]] &&
        [[ -z "$USED_IN_SAME_FILE" ]] && COMPONENTS+=("$FUNCTION;$FILE_PATH")
    fi
    AUX_ARRAY_COMPONENTS=${COMPONENTS[@]}
  done
}

getES5FunctionComponents() {
  CURRENT_FUNCTIONS=$(cat ${FILE_PATH} | grep -o "function.*(" | awk '{  print $2 }' | cut -d "(" -f 1)
  checkFunctions
}

getES6FunctionComponents() {
  CURRENT_FUNCTIONS=$(cat ${FILE_PATH} | grep -o "const.*= (.*) =>" | awk '{  print $2 }')
  checkFunctions
}

getFunctionComponents() {
  IS_REACT_FILE=$(cat ${FILE_PATH} | grep 'import.*React')
  if [ ! -z "$IS_REACT_FILE" ]; then
    getES5FunctionComponents
    getES6FunctionComponents
  fi
}

getComponents() {
  for ITEM in $FIND_RETURN; do
    FILE_PATH=$ITEM
    getClassComponents
    getFunctionComponents
  done
}

searchImports() {
  GREP_RECURSIVE_RESULT=''
  for COMPONENT in ${COMPONENTS[@]}; do
    COMPONENT_NAME=$(echo $COMPONENT | cut -d ";" -f 1)
    COMPONENT_FILE_PATH=$(echo $COMPONENT | cut -d ";" -f 2)
    GREP_RECURSIVE_RESULT=$(echo $FIND_RETURN | xargs grep "import.*$COMPONENT_NAME.*from")
    COMPONENTS_OCURRENCES=$([[ -z "$GREP_RECURSIVE_RESULT" ]] && echo 0 || (echo "$GREP_RECURSIVE_RESULT" | wc -l))
    COMMENTED_IMPORT_OCCURRENCES=$(echo "$GREP_RECURSIVE_RESULT" | grep // | wc -l)
    if [ "$COMPONENTS_OCURRENCES" = 0 ] || [ "$COMPONENTS_OCURRENCES" = "$COMMENTED_IMPORT_OCCURRENCES" ]; then
      ((COUNTER_UNUSED_COMPONENTS++))
      FILE_SIZE=$(fileSizeKB $COMPONENT_FILE_PATH)
      [[ -z $RAW ]] && printf "\e[39m%40s | \e[35m%s | \e[33m%s %s\n" $COMPONENT_NAME $COMPONENT_FILE_PATH $FILE_SIZE || echo "$COMPONENT_NAME | $COMPONENT_FILE_PATH | $FILE_SIZE"
    fi
    AUX_COUNTER=$COUNTER_UNUSED_COMPONENTS
  done
}

showResult() {
  handleResult "Results"
  if [ $COUNTER_UNUSED_COMPONENTS -eq 0 ]; then
    handleResult "No unused components found"
  else
    handleResult "$COUNTER_UNUSED_COMPONENTS possible dead components :/" '\e[0m'
  fi
  BROWSED_FILES=$(echo "${FIND_RETURN/ /\n}" | wc -l)
  handleResult "$BROWSED_FILES browsed files in $FINDEAD_TIME seconds"
}

handleResult() {
  [[ -z $RAW ]] && centerResult "$1" || echo "$1"
}

main() {
  searchFiles && getComponents && searchImports
}

initStyle() {
  TERM=xterm-256color
  tput -T xterm clear
  tput -T xterm cup 1 0
  tput -T xterm rev
  tput -T xterm bold
  center 'Findead is looking for components...'
  tput -T xterm sgr0
  tput -T xterm cup 3 0
}

start() {
  [[ -z $RAW ]] && initStyle
  PATH_TO_FIND=$1
  { time main; } 2>findead_execution_time.txt
  FINDEAD_TIME=$(cat findead_execution_time.txt)
  showResult
  rm -rf findead_execution_time.txt
  [[ -z $RAW ]] && unset TIMEFORMAT
}

if [[ $FIRST_ARGUMENT == "--version" || $FIRST_ARGUMENT == "-v" ]]; then
  echo "findead@1.1.2"
elif [[ $FIRST_ARGUMENT == "--help" || $FIRST_ARGUMENT == "-h" ]]; then
  cat <<EOF

  findead is used for looking for possible unused components(Dead components)

  usage:
    findead path/to/search/
    findead -r path/to/search/
    findead -m path/to/search/{folder1,folder3}
    findead -h | --help
    findead -v | --version

  report bugs to: https://github.com/narcello/findead/issues

EOF
elif [[ ! -z $MULTIPLE_PATHS || ! -z $RAW ]]; then
  ARRAY_PARAMS=($@)
  PATHS=${ARRAY_PARAMS[@]:1}
  start "$PATHS"
else
  start $FIRST_ARGUMENT
fi
