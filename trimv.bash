#!/bin/bash
trimv() {
  if(($#)); then
    if [[ $1 == '-n' ]]; then
      local -g TRIM
      declare -n Var=${2:-TRIM}
      shift 2
    fi
  fi
  if(($#)); then
    local -- v="$*"
    v="${v#"${v%%[![:blank:]]*}"}"
    if [[ -R Var ]]; then
      Var="${v%"${v##*[![:blank:]]}"}"
    else
      echo -n "${v%"${v##*[![:blank:]]}"}"
    fi
  else
    local -- REPLY
    while read -r; do
      REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}"
      if [[ -R Var ]]; then
        Var+="${REPLY%"${REPLY##*[![:blank:]]}"}\n"
      else
        echo -n "${REPLY%"${REPLY##*[![:blank:]]}"}"
      fi
    done
  fi
}
declare -fx trimv
