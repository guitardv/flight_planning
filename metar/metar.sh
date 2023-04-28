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

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# tput colors
FluorGreen=46
SkyBlue=81
PureWhite=15
ExtraLightGrey=253
LightGrey=250
Grey248=248
Grey=244
DarkGrey=236
DynamiteRed=9
StandardYellow=3

# tput setaf <int> changes font color
# tput colors return the number of supported colors (8 or 256)
# if 8: 0 to 7 are colors, 8 isn't attributed, and 9 is default
# tput sgr0 reset the terminal to its default configuration
if [ $(tput colors) -eq 256 ] ; then
    logoColor=$SkyBlue
    copyrightColor=$PureWhite
    borderColor=$Grey248
    menuTitleColor=$PureWhite
    menuLabelColor=$ExtraLightGrey
    menuItemColor=$ExtraLightGrey
    menuItemNumberColor=$StandardYellow
    menuQueryColor=$ExtraLightGrey
    menuChoiceColor=$menuItemNumberColor
    menuBorderColor=$Grey248
    warningMessage=$DynamiteRed
else
    logoColor=4 # blue
    copyrightColor=7 # white
    borderColor=9 # default
    menuTitleColor=7
    menuLabelColor=9
    menuItemColor=9
    menuItemNumberColor=$StandardYellow # yellow
    menuQueryColor=9
    menuChoiceColor=$menuItemNumberColor
    menuBorderColor=9
    warningMessage=1 # red
fi


MetarMenu()
{
    # generate a "prefix" indentation to have the menu centered in the terminal
    menuWidth=79
    COLUMNS=$(tput cols)
    indent=$(( (COLUMNS - menuWidth) / 2 ))
    choiceIndent=$(( indent / 2 ))
    prefix=''
    choicePrefix=''
    for ((i=1; i<=indent; i++)) ; do
        prefix+=' '
        if [ $i -le $choiceIndent ] ; then
            choicePrefix+=' '
        fi
    done

    echo
    echo
    echo "$(tput setaf $menuBorderColor)$prefix+-----------------------------------------------------------------------------+"
    echo "$prefix!$(tput setaf $menuTitleColor)                                    METAR                                    $(tput setaf $menuBorderColor)!"
    echo "$prefix+-----+----------+------------------------------------------------------------+"
    echo "$prefix!$(tput setaf $menuLabelColor) Nbr $(tput setaf $menuBorderColor)!$(tput setaf $menuLabelColor) Choice $(tput setaf $menuBorderColor)  !$(tput setaf $menuLabelColor) Detail   $(tput setaf $menuBorderColor)                                                  !"
    echo "$prefix+-----+----------+------------------------------------------------------------+"
    echo "$prefix!$(tput setaf $menuItemNumberColor)  1  $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Display  $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Retrieve and display METAR for specified locations         $(tput setaf $menuBorderColor)!"
    echo "$prefix+-----+----------+------------------------------------------------------------+"
    echo "$prefix!$(tput setaf $menuItemNumberColor)  2  $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Print   $(tput setaf $menuBorderColor) !$(tput setaf $menuItemColor) Retrieve and print METAR for specified locations           $(tput setaf $menuBorderColor)!"
    echo "$prefix+-----+----------+------------------------------------------------------------+"
    echo "$prefix!$(tput setaf $menuItemNumberColor)  3  $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Both    $(tput setaf $menuBorderColor) !$(tput setaf $menuItemColor) Retrieve, display, and print METAR for specified locations $(tput setaf $menuBorderColor)!"
    echo "$prefix+-----+----------+------------------------------------------------------------+"
    echo "$prefix!$(tput setaf $menuItemNumberColor)  m  $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Menu    $(tput setaf $menuBorderColor) !$(tput setaf $menuItemColor) Go to main menu                                            $(tput setaf $menuBorderColor)!"
    echo "$prefix+-----+----------+------------------------------------------------------------+"
    echo "$prefix!$(tput setaf $menuItemNumberColor)  q  $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Quit     $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Quit to terminal                                           $(tput setaf $menuBorderColor)!"
    echo "$prefix+-----+----------+------------------------------------------------------------+"
    echo
    printf "$(tput setaf $menuQueryColor)$choicePrefix""Choice number: "
    tput setaf $menuChoiceColor
    read menuChoice
    tput sgr0

    case $menuChoice in
        1) DisplayMetar --interactive ;;
        2) PrintMetar --interactive ;;
		3) DisplayAndPrintMetar --interactive ;;
        m | M) exit 0 ;;
		q | Q) touch $SCRIPT_DIR/.quit ; echo ; exit 0 ;;
        *) tput setaf $warningMessage ; echo ; echo "$choicePrefix""Unrecognised option" ; tput sgr0 ; MetarMenu ;;
    esac
}

DisplayMetar()
{
	echo
    tput setaf $menuQueryColor
    printf "$choicePrefix""Enter the ICAO locations of interest separeted by a space and between quotation marks (default: \"CYUL CYHU\"): "
    tput setaf $menuChoiceColor
    read icaoMetarLocations
    tput sgr0
    echo
    if [ "$icaoMetarLocations" == "" ] ; then icaoMetarLocations="CYUL CYHU" ; fi

    python3 "$SCRIPT_DIR/metar.py" $icaoMetarLocations 2>> "$SCRIPT_DIR/.metar.log"

	if [ "$1" == "--interactive" ] ; then
	    echo
        read -s -n 1 -p "$choicePrefix""Press any key to continue to main menu."
	    exit 0
    fi
}

PrintMetar()
{
	echo "Print"
	sleep 2
	exit 0
}

DisplayAndPrintMetar()
{
	echo "Display and print"
	if [ "$1" == "--interactive" ] ; then
	    echo
        read -s -n 1 -p "$choicePrefix""Press any key to continue to main menu."
	    exit 0
    fi
}

InitialiseLog()
{
    if [ -f $SCRIPT_DIR/.metar.log ] ; then
	    logFileSize=$( wc -c $SCRIPT_DIR/.metar.log | awk '{print $1}' )
	    # If the log file is larger than 100kb, empty it
	    if [ $logFileSize -gt 100000 ] ; then echo '' > $SCRIPT_DIR/.metar.log ; fi
	    unset logFileSize
    else
	    touch $SCRIPT_DIR/.metar.log
    fi
}

InitialiseLog
date '+%F %T-%Z' >> $SCRIPT_DIR/.metar.log

# if the script is called in interactive mode
if [ "$1" == "--interactive" ] ; then
    echo "Entering interactive mode" >> $SCRIPT_DIR/.metar.log
	MetarMenu
	exit 1 # should only exit via MetarMenu, if the script continue past the function, a problem occured
fi

# if the script is called at startup by the headless acount
sleep 15

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
