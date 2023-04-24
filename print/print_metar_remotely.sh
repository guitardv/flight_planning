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

# This script relay its arguments to the print_metar.sh on the raspberry pi
# I suggest you give this script the alias metarp in your .bash_aliases, for ease of use
# The RPi ip is stored in printer/SECRET/printer_ip
# The RPi user id is stored in printer/SECRET/user_id
# The path to the flight_planning repo on the RPi is stored in printer/SECRET/repo_path

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
Printer_ip=$( cat "$SCRIPT_DIR/SECRET/printer_ip" )
User_id=$( cat "$SCRIPT_DIR/SECRET/user_id" )
Repo_path=$( cat "$SCRIPT_DIR/SECRET/repo_path" )

ssh -t $User_id@$Printer_ip "bash $Repo_path/print/print_metar.sh $@"