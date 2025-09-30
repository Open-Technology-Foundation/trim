#!/bin/bash

rtrim () 
{ 
    if (($#)); then
        local -- v;
        if [[ $1 == '-e' ]]; then
            shift;
            v="$(echo -en "$*")";
        else
            v="$*";
        fi;
        echo -n "${v%"${v##*[![:blank:]]}"}";
        return 0;
    fi;
    if [[ ! -t 0 ]]; then
        local -- REPLY;
        while IFS= read -r REPLY || [[ -n "$REPLY" ]]; do
            REPLY="${REPLY%"${REPLY##*[![:blank:]]}"}";
            echo "$REPLY";
        done;
    fi
}
declare -fx rtrim

trimv () 
{ 
    local -- process_escape=false;
    local -- varname="";
    if (($#)); then
        if [[ $1 == '-e' ]]; then
            process_escape=true;
            shift;
        fi;
        if [[ ${1:-} == '-n' ]]; then
            varname="${2:-TRIM}";
            if ! [[ $varname =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                echo "Error: Invalid variable name '$varname'" 1>&2;
                return 1;
            fi;
            export _TRIMV_VARNAME="$varname";
            [[ -z "${!varname+x}" ]] && eval "$varname=''";
            shift 2;
        fi;
    fi;
    if (($#)); then
        local -- v;
        if [[ $process_escape == true ]]; then
            v="$(echo -en "$*")";
        else
            v="$*";
        fi;
        v="${v#"${v%%[![:blank:]]*}"}";
        v="${v%"${v##*[![:blank:]]}"}";
        if [[ -n "$varname" ]]; then
            eval "$varname=\"\$v\"";
        else
            echo -n "$v";
        fi;
        return 0;
    fi;
    if [[ ! -t 0 ]]; then
        if [[ -n "$varname" ]]; then
            local -- tmp_file;
            tmp_file=$(mktemp -t "trimv_XXXXXXXXXX");
            chmod 600 "$tmp_file";
            local -- REPLY;
            while IFS= read -r REPLY || [[ -n "$REPLY" ]]; do
                REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}";
                REPLY="${REPLY%"${REPLY##*[![:blank:]]}"}";
                echo "$REPLY" >> "$tmp_file";
            done;
            if [[ -s "$tmp_file" ]]; then
                local -- content;
                content=$(< "$tmp_file");
                eval "$varname=\"\$content\"";
            else
                eval "$varname=''";
            fi;
            rm -f "$tmp_file" 2> /dev/null || true;
        else
            local -- REPLY;
            while IFS= read -r REPLY || [[ -n "$REPLY" ]]; do
                REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}";
                REPLY="${REPLY%"${REPLY##*[![:blank:]]}"}";
                echo "$REPLY";
            done;
        fi;
    fi
}
declare -fx trimv

ltrim () 
{ 
    if (($#)); then
        local -- v;
        if [[ $1 == '-e' ]]; then
            shift;
            v="$(echo -en "$*")";
        else
            v="$*";
        fi;
        echo -n "${v#"${v%%[![:blank:]]*}"}";
        return 0;
    fi;
    if [[ ! -t 0 ]]; then
        local -- REPLY;
        while IFS= read -r REPLY || [[ -n "$REPLY" ]]; do
            REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}";
            echo "$REPLY";
        done;
    fi
}
declare -fx ltrim

squeeze () 
{ 
    local -- process_escape=false;
    if [[ "${1:-}" == '-e' ]]; then
        process_escape=true;
        shift;
    fi;
    if (($#)); then
        local -- v;
        if [[ $process_escape == true ]]; then
            v="$(echo -en "$*")";
        else
            v="$*";
        fi;
        v="${v//'	'/ }";
        while [[ $v =~ "  " ]]; do
            v="${v//  / }";
        done;
        echo -n "$v";
        return 0;
    fi;
    if [[ ! -t 0 ]]; then
        local -- REPLY;
        while IFS= read -r REPLY || [[ -n "$REPLY" ]]; do
            REPLY="${REPLY//'	'/ }";
            while [[ $REPLY =~ "  " ]]; do
                REPLY="${REPLY//  / }";
            done;
            echo "$REPLY";
        done;
    fi
}
declare -fx squeeze

trimall () 
{ 
    local -- process_escape=false;
    if [[ "${1:-}" == '-e' ]]; then
        process_escape=true;
        shift;
    fi;
    if (($#)); then
        local -- v;
        if [[ $process_escape == true ]]; then
            v="$(echo -en "$*")";
        else
            v="$*";
        fi;
        set -f;
        set -- $v;
        echo -n "$*";
        set +f;
        return 0;
    fi;
    if [[ ! -t 0 ]]; then
        local -- content="";
        local -- line;
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -n "$content" ]] && content+=" ";
            content+="$line";
        done;
        if [[ -n "$content" ]]; then
            set -f;
            set -- $content;
            echo -n "$*";
            set +f;
        fi;
    fi
}
declare -fx trimall

trim () 
{ 
    if (($#)); then
        local -- v;
        if [[ $1 == '-e' ]]; then
            shift;
            v="$(echo -en "$*")";
        else
            v="$*";
        fi;
        v="${v#"${v%%[![:blank:]]*}"}";
        echo -n "${v%"${v##*[![:blank:]]}"}";
        return 0;
    fi;
    if [[ ! -t 0 ]]; then
        local -- REPLY;
        while IFS= read -r REPLY || [[ -n "$REPLY" ]]; do
            REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}";
            REPLY="${REPLY%"${REPLY##*[![:blank:]]}"}";
            echo "$REPLY";
        done;
    fi
}
declare -fx trim

#fin
