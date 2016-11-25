#!/bin/sh

if [ -z "$1" ]; then
	echo Must specify where is the CPN file
	exit 1
fi

awk '/<ssnode/,/<\/ssnode>/' "$1" | awk '/<text>/,/<\/text>/' | sed -e '/<text>/{:l N;/<\/text>/b; s/\n//; bl};' | sed -e '/<\/text>/d' -re 's/\s+<text>([0-9]+):/\1 /' > Ex_1_3_state_space.txt


