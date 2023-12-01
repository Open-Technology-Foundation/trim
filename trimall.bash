#!/usr/bin/env bash
#@ Function : trim ltrim rtrim trimv trimall
#@ Desc     : Delete leading/trailing blank characters from a string or
#@          : stream.
#@          :
#@          : Blank charaters are space, tab, and new-line.
#@          :
#@          :   trim    strip string/file of leading+trailing blank chars.
#@          :   ltrim   strip string/file of leading blank chars.
#@          :   rtrim   strip string/file of trailing blank chars.
#@          :   trimv   assign stripped string to variable.
#@          :   trimall strip string/file of trailing blank chars and double spaces within string.
#@          :
#@ Synopsis : trim [-e] string|-
#@          : ltrim string|-
#@          : rtrim string|-
#@          : trimv -n varname string|-
#@          : trimall string|-
#@          :
#@ Examples : #0) strip spaces from around 'str'
#@          : str=" 123 "; str=$(trim "$str")
#@          :
#@          : #1) remove all leading+trailing blanks.
#@          : trim <fat.file >thin.file
#@          :
#@          : #2) remove trailing blanks from file.
#@          : rtrim <fat.file >lean.file
#@          :
#@          : #3) remove all leading+trailing blanks from file, scenic route.
#@          : rtrim <fat.file | ltrim >thin.file
#@          :
#@          : #4) Assign stripped string to varname.
#@          : trimv -n myvar "  This   is  a messy string.  "
#@          : echo "$myvar"
#@          :
#don't judge me.
#shellcheck disable=SC2048,SC2086
trimall() {
    # Usage: trimall "   example   string    "
    set -f
    set -- $*
    printf '%s\n' "$*"
    set +f
}
declare -fx trimall
