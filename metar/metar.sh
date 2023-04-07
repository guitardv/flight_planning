#!/usr/bin/env bash

##############################################################################
# Copyright 2023 Vincent Guitard
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#   See also the project README file for additional clauses.
#   You may obtain a copy of the README file at
#       https://github.com/guitardv/flight_planning/blob/main/README.md
##############################################################################

# The point of this script is to automate the launch of metar.py at startup and keeping it alive in case of failure.
# It's meant to be called from the .bashrc using /bin/bash in a rbash + PATH restricted headless user.

sleep 15

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ -a $SCRIPT_DIR/.metar.log ] ; then
	logFileSize=$( wc -c $SCRIPT_DIR/.metar.log | awk '{print $1}' )
	# If the log file is larger than 100kb, empty it
	if [ $logFileSize -gt 100000 ] ; then echo '' > $SCRIPT_DIR/.metar.log ; fi
	unset logFileSize
else
	touch $SCRIPT_DIR/.metar.log
fi

date '+%F %T-%Z' >> $SCRIPT_DIR/.metar.log

# I get the argument passed to this script to pass them to the python script
for argumentSHcurrent in $@ ; do
	if [ $argumentSHcurrent != $0 ] ; then argumentsSH=$argumentsSH' '$argumentSHcurrent ; fi
done

python3 "$SCRIPT_DIR/metar.py" $argumentsSH 2>> "$SCRIPT_DIR/.metar.log"

status=$?

# if the python script exit with a non 0 code (failure), start it again after a 5 seconds pause
while [ "$status" -ne 0 ] ; do
        sleep 5
        date '+%F %T-%Z' >> $SCRIPT_DIR/.metar.log
        python3 $SCRIPT_DIR/metar.py $argumentsSH 2>> $SCRIPT_DIR/.metar.log
        status=$?
done
