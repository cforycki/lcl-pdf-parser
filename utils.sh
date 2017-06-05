#!/usr/bin/env bash

function log() {
    if [ ${_VERBOSE} -ge 1 ]; then
        echo "$@"
    fi
}

function printHelp() {
    echo "TODO print help"
}

function writeToFile() {
    FILE=$1
    log "Writing to file : $FILE"
    if [ -n ${FILE} ]; then
        DEBITS=$2
        CREDITS=$3
        echo "$DEBITS" >>${FILE}
        echo "$CREDITS" >>${FILE}
    fi
}