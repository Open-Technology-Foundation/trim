#!/bin/bash
rtrim() {
	if(($#)); then
		local v="$*"
		echo "${v%"${v##*[![:blank:]]}"}"   
	else
		local REPLY
		while IFS= read -r; do
			echo "${REPLY%"${REPLY##*[![:blank:]]}"}"
		done
	fi
}
declare -fx rtrim
