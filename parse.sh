#!/bin/bash

## Globals
declare _VERBOSE=0
declare _OUTPUT_FILE=""

## Sources
. ./utils.sh

## Options handling
while getopts ":vo:" opt; do
    case $opt in
        v)
            _VERBOSE=1;
        ;;
        o)
            _OUTPUT_FILE=$OPTARG
            >${_OUTPUT_FILE}
        ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            printHelp
            exit 1
        ;;
    esac
done

## Remaining args
shift $((OPTIND - 1))

## Main loop
for file in $@
do
    OUTPUT=$(gs -dBATCH -dSAFER -q -dNOPAUSE -sDEVICE=txtwrite -sOutputFile=- $file 2>/dev/null)
    DATES=$(echo "$OUTPUT" | perl -ne '$first != 1 and /du\s*?(\d{2}\.\d{2}\.\d{4})\s*?au\s*?(\s*?\d{2}\.\d{2}\.\d{4}).*/ and print "$1;$2" and $first = 1');
    DEBITS=$(echo "$OUTPUT" | perl -ne '/^\s*(?:\d{2}\.\d{2})\s*(.*?)\s*(\d{2})\.(\d{2})\.(\d{2})[\s\.]{0,18}(\d+(?:\s+\d+)*,\d+).*?/ and print "$2-$3-$4;0;;;$1;-$5;;\n"')
    CREDITS=$(echo "$OUTPUT" | perl -ne '/^\s*(?:\d{2}\.\d{2})\s*(.*?)\s*(\d{2})\.(\d{2})\.(\d{2})[\s\.]{19,}(\d+(?:\s+\d+)*,\d+).*?/ and print "$2-$3-$4;0;;;$1;$5;;\n"');
    ANCIEN_SOLDE=$(echo "$OUTPUT" | perl -ne '/^\s*(?:\d{2}\.\d{2})\s*ANCIEN SOLDE(\s*)(\d+(?:\s+\d+)*,\d+)?.*?/ and print ((length($1) > 18)?"$2":"-$2")');
    SOLDE=$(echo "$OUTPUT" | perl -ne '/^\s*(?:\d{2}\.\d{2})\s*SOLDE EN EUROS(\s*)(\d+(?:\s+\d+)*,\d+)?.*?/ and print ((length($1) > 18)?"$2":"-$2")');

    writeToFile ${_OUTPUT_FILE} "${DEBITS}" "${CREDITS}"
    log "Fichier : $file"
    log "Dates :  $DATES"
    log
    log "Ancien solde : $ANCIEN_SOLDE"
    log "Nouveau solde : $SOLDE"
    log
    log 'Debits : '
    log "$DEBITS"
    log
    log 'Credits : '
    log "$CREDITS"
    log
done