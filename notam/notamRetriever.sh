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

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

airportList="CYHU CSY3" # default list of ICAO locations to retreive a notam from
isatest=false # if it's a test and I already have data from the desired airport, don't download it again
#locationRadius=0 # radius around provided location, in NM
outputFileName="notam.txt"
PATH_outputFile="$SCRIPT_DIR/$outputFileName"

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

Help()
{
    echo
    echo "Retreive NOTAMs for specified locations from the NOTAM FAA API and format them for human readability."
    echo
    echo "Usage:"
    echo " $(basename $0) [options]"
    echo " $(basename $0) [options] -o|--output <file>"
    echo
    echo "Options:"
    echo "-t, --test            use local raw NOTAM data if available"
    echo "-a, --airport <ICAO>  retreive NOTAMs associated to specified ICAO"
    echo "                      locations, if multiple locations are provided"
    echo "                      use quotation marks and separate locations"
    echo "                      with a space, eg.: \"CYHU CYUL\""
    echo "                      default value: \"$airportList\""
#    echo "-r, --radius <int>    search radius around provided locations in NM,"
#    echo "                      default value: $locationRadius, max = 100"
    echo "-o, --output <file>   generated human readable NOTAMS will be saved"
    echo "                      in the specified file,"
    echo "                      default value: $outputFileName"
    echo "-h, --help            display this help message and exit"
    echo
    echo "API Key:"
    echo "Usage of the NOTAM FAA API requires the use of a client id and of a"
    echo "client key. The client id and client key should be stored in the"
    echo "subfolder \"SECRET\" under the name \"api_client_id\" and"
    echo "\"api_client_secret\", respectively and without any extra character."
    echo "To obtain an API key or for more information about the FAA NOTAM API,"
    echo "see: https://api.faa.gov ."
    echo
    echo "Test:"
    echo "If the option -t or --test is used, raw NOTAM data will be imported"
    echo "from files in the \"example\" subfolder, if available, instead of being"
    echo "downloaded. Example files names should start with the ICAO location"
    echo "id (uppercase) and end with an extansion corresponding to their format"
    echo "(.geoJSON or .aixm)."
    echo "Eg.: ./example/CYHU.geoJSON or ./example/KRSW_20230406.aixm"
    echo "/!\ The only format supported for now is geoJSON."
}

NotamMenu()
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
    echo "$prefix!$(tput setaf $menuTitleColor)                                    NOTAM                                    $(tput setaf $menuBorderColor)!"
    echo "$prefix+-----+----------+------------------------------------------------------------+"
    echo "$prefix!$(tput setaf $menuLabelColor) Nbr $(tput setaf $menuBorderColor)!$(tput setaf $menuLabelColor) Choice $(tput setaf $menuBorderColor)  !$(tput setaf $menuLabelColor) Detail   $(tput setaf $menuBorderColor)                                                  !"
    echo "$prefix+-----+----------+------------------------------------------------------------+"
    echo "$prefix!$(tput setaf $menuItemNumberColor)  1  $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Display  $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Retrieve and display NOTAM for specified locations         $(tput setaf $menuBorderColor)!"
    echo "$prefix+-----+----------+------------------------------------------------------------+"
    echo "$prefix!$(tput setaf $menuItemNumberColor)  2  $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Print   $(tput setaf $menuBorderColor) !$(tput setaf $menuItemColor) Retrieve and print NOTAM for specified locations           $(tput setaf $menuBorderColor)!"
    echo "$prefix+-----+----------+------------------------------------------------------------+"
    echo "$prefix!$(tput setaf $menuItemNumberColor)  3  $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Both    $(tput setaf $menuBorderColor) !$(tput setaf $menuItemColor) Retrieve, display, and print NOTAM for specified locations $(tput setaf $menuBorderColor)!"
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
        1) DisplayNotam ;;
        2) PrintNotam ;;
		3) DisplayAndPrintNotam ;;
        m | M) exit 0 ;;
		q | Q) touch $SCRIPT_DIR/.quit ; echo ; exit 0 ;;
        *) tput setaf $warningMessage ; echo ; echo "$choicePrefix""Unrecognised option" ; tput sgr0 ; NotamMenu ;;
    esac
}

DisplayNotam()
{
    echo "Display"
    echo
    read -s -n 1 -p "$choicePrefix""Press any key to continue to main menu."
    exit 0
}

PrintNotam()
{
    echo "Print"
    sleep 2
    exit 0
}

DisplayAndPrintNotam()
{
    echo "Display and print"
    echo
    read -s -n 1 -p "$choicePrefix""Press any key to continue to main menu."
    exit 0
}

# if the script is called in interactive mode
if [ "$1" == "--interactive" ] ; then
	NotamMenu
	exit 1 # should only exit via NotamMenu, if the script continue past the function, a problem occured
fi

VALID_ARGS=$(getopt -o tha:o: -l test,help,airport:,output: -n "$(basename $0)" -- "$@")

eval set -- "$VALID_ARGS"
while [ : ] ; do
    case "$1" in
        -t | --test)
            echo -e "/!\\ /!\\ Test mode /!\\ /!\\ \nGenerated information cannot be used for flight preparation.\n"
            isatest=true
            shift
            ;;
        -a | --airport)
            # if the first character of the argument is a dash, ICAO locations are missing
            # else, add the airport IDs
            if [ ${2:0:1} == '-' ] ; then
                echo -e "$(basename $0): missing argument for option $1\nTry \"$(basename $0) --help\" for more information."
                exit 1
            else
                airportList=$2
                shift 2
            fi
            ;;
#        -r | --radius)
            # if the first character of the argument is a dash, the radius is missing
            # else, add the radius
#            if [ ${2:0:1} == '-' ] ; then
#                echo -e "$(basename $0): missing argument for option $1\nTry \"$(basename $0) --help\" for more information."
#                exit 1
#            else
#                if [ $(($2)) -gt 100 ] ; then
#                    echo -e "$(basename $0): argument for option $1 exceed the maximum value of 100.\nTry \"$(basename $0) --help\" for more information."
#                    exit 1
#                else
#                    locationRadius=$2
#                    shift 2
#                fi
#            fi
#            ;;
        -o | --output)
            # if the first character of the argument is a dash, output file name is missing
            # else, add the output file name
            if [ ${2:0:1} == '-' ] ; then
                echo -e "$(basename $0): missing argument for option $1\nTry \"$(basename $0) --help\" for more information."
                exit 1
            else
                PATH_outputFile=$2
                shift 2
            fi
            ;;
        -h | --help)
            #echo "Usage: $(basename $0) [-t] [-h] [-a arg]"
            Help
            exit 0
            ;;
        --) shift;
            break
            ;;
    esac
done
unset VALID_ARGS
unset outputFileName # only used for the default file name, use PATH_outputFile for the file path


# if the destination temporary file exist, empty it and print a warning message, else create it empty
if [ -a "$PATH_outputFile.tmp" ] ; then
    echo "" > "$PATH_outputFile.tmp"
    echo "$(basename $0): Warning: temporary file $PATH_outputFile.tmp wasn't deleted correctly during last session."
else
    touch "$PATH_outputFile.tmp"
fi

# if it's a test and I already have data from the desired airport, don't download it again
if [ "$isatest" == true ] ; then
    echo "test"
else
    client_id=$(cat "$SCRIPT_DIR/SECRET/api_client_id")
    client_secret=$(cat "$SCRIPT_DIR/SECRET/api_client_secret")
    airportList=${airportList^^} # make all ICAO ids uppercase
    airportList=($airportList) #convert the string into an array using spaces as separators
    for currentICAOlocation in ${airportList[@]} ; do
        echo
        echo "Downloading NOTAMs for $currentICAOlocation:"
        curl "https://external-api.faa.gov/notamapi/v1/notams?responseFormat=geoJson&icaoLocation=$currentICAOlocation&sortBy=icaoLocation&sortOrder=Asc" -H "client_id:$client_id" -H "client_secret:$client_secret" >> "$PATH_outputFile.tmp"
    done
    unset client_id
    unset client_secret
fi


exit 0
