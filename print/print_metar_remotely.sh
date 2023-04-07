#!/usr/bin/env bash

# This script relay its arguments to the print_metar.sh on my raspberry pi
# I gave this script the alias metarp in my .bash_aliases
# The RPi ip is stored in printer/SECRET/printer_ip
# The RPi user id is stored in printer/SECRET/user_id
# The path to the flight_planning repo on my RPi is stored in printer/SECRET/repo_path

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
Printer_ip=$( cat "$SCRIPT_DIR/SECRET/printer_ip" )
User_id=$( cat "$SCRIPT_DIR/SECRET/user_id" )
Repo_path=$( cat "$SCRIPT_DIR/SECRET/repo_path" )

ssh -t $User_id@$Printer_ip "bash $Repo_path/print/print_metar.sh $@"