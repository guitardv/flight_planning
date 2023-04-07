#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ $# -gt 0 ] ; then
    for argumentSHcurrent in $@ ; do
	    if [ $argumentSHcurrent != $0 ] ; then argumentsSH=$argumentsSH' '$argumentSHcurrent ; fi
    done
    python3 "$SCRIPT_DIR/metar.py" $argumentsSH | python3 "$SCRIPT_DIR/print_metar.py"
else
    python3 "$SCRIPT_DIR/metar.py" | python3 "$SCRIPT_DIR/print_metar.py"
fi
