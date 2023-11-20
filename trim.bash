#!/bin/bash
#@ Function : trim ltrim rtrim
#@ Desc     : Delete leading/trailing blank characters from a string or 
#@          : stream.
#@          :
#@          : Blank charaters are space, tab, and new-line.
#@          :   
#@          :   trim    strip string/file of leading+trailing blank chars.
#@          :   ltrim   strip string/file of leading blank chars.
#@          :   rtrim   strip string/file of trailing blank chars.
#@          :
#@ Synopsis : trim [-e] string|-
#@          : ltrim string|-
#@          : rtrim string|-
#@          :
#@ Examples : #0) strip spaces from around 'str'
#@          : str=" 123 "; str=$(trim "$str")
#@          : 
#@          : #1) remove all leading+trailing blanks.
#@          : trim <fat.file >thin.file
#@:
#@          : #2) remove trailing blanks from file.
#@          : rtrim <fat.file >lean.file
#@:
#@          : #3) remove all leading+trailing blanks from file, slow way.
#@          : rtrim <fat.file | ltrim >thin.file
#@:
trim() {
  if (($#)); then
    local -- v
    if [[ $1 == '-e' ]]; then
      shift
      v="$(echo -en "$*")"
    else
      v="$*"
    fi
    v="${v#"${v%%[![:blank:]]*}"}"
    echo -n "${v%"${v##*[![:blank:]]}"}"
    return 0
  fi
  if [[ ! -t 0 ]]; then
    local -- REPLY
    while read -r; do
      REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}"
      echo "${REPLY%"${REPLY##*[![:blank:]]}"}"
    done
  fi
}
declare -fx trim

#fin
