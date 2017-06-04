#!/bin/bash

for file in $@
do
	OUTPUT=$(gs -dBATCH -dSAFER -q -dNOPAUSE -sDEVICE=txtwrite -sOutputFile=- $file 2>/dev/null)
	DATES=$(echo "$OUTPUT" | perl -ne '$first != 1 and /du\s*?(\d{2}\.\d{2}\.\d{4})\s*?au\s*?(\s*?\d{2}\.\d{2}\.\d{4}).*/ and print "$1;$2" and $first = 1');
	DEBITS=$(echo "$OUTPUT"| perl -ne '/^\s*(?:\d{2}\.\d{2})\s*(.*?)\s*(\d{2})\.(\d{2})\.(\d{2})[\s\.]{0,18}(\d+(?:\s+\d+)*,\d+).*?/ and print "$2-$3-$4;0;;;$1;-$5;;\n"')
	CREDITS=$(echo "$OUTPUT" | perl -ne '/^\s*(?:\d{2}\.\d{2})\s*(.*?)\s*(\d{2})\.(\d{2})\.(\d{2})[\s\.]{19,}(\d+(?:\s+\d+)*,\d+).*?/ and print "$2-$3-$4;0;;;$1;$5;;\n"');
	ANCIEN_SOLDE=$(echo "$OUTPUT" | perl -ne '/^\s*(?:\d{2}\.\d{2})\s*ANCIEN SOLDE(\s*)(\d+(?:\s+\d+)*,\d+)?.*?/ and print ((length($1) > 18)?"$2":"-$2")');
	SOLDE=$(echo "$OUTPUT" | perl -ne '/^\s*(?:\d{2}\.\d{2})\s*SOLDE EN EUROS(\s*)(\d+(?:\s+\d+)*,\d+)?.*?/ and print ((length($1) > 18)?"$2":"-$2")');

	echo "Fichier : $file"
	echo "Dates :  $DATES"
	echo
	echo "Ancien solde : $ANCIEN_SOLDE"
	echo "Nouveau solde : $SOLDE"
	echo
	echo 'Debits : '
	echo "$DEBITS"
	echo
	echo 'Credits : '
	echo "$CREDITS"
	echo
done