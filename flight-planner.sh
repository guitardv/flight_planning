
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

MainLogo()
{

    # generate a "prefix" indentation to have the logo centered in the terminal
    banner_width=79
    COLUMNS=$(tput cols)
    indent=$(( (COLUMNS - banner_width) / 2 ))
    borderIndent=$(( indent / 2 ))
    borderLength=$(( COLUMNS - indent ))
    borderLine=''
    prefix=''
    for ((i=1; i<=indent; i++)) ; do
        prefix+=' '
        if [ $i -le $borderIndent ] ; then
            borderLine+=' '
        fi
    done

    for ((i=1; i<=borderLength; i++)) ; do
        borderLine+='='
    done


    # ASCII text generated with: https://patorjk.com/software/taag/#p=display&h=1&v=0&f=Slant&t=Flight%20Planner
    # Font: Slant, Character width: Fitted, Character Height: Full
    cat << EOF
$(tput setaf $borderColor)$borderLine$(tput setaf $logoColor)
$prefix    ______ __ _         __     __     ____   __                                
$prefix   / ____// /(_)____ _ / /_   / /_   / __ \ / /____ _ ____   ____   ___   _____
$prefix  / /_   / // // __ \`// __ \ / __/  / /_/ // // __ \`// __ \ / __ \ / _ \ / ___/
$prefix / __/  / // // /_/ // / / // /_   / ____// // /_/ // / / // / / //  __// /    
$prefix/_/    /_//_/ \__, //_/ /_/ \__/  /_/    /_/ \__,_//_/ /_//_/ /_/ \___//_/     
$prefix             /____/                                                            
$prefix $(tput setaf $copyrightColor)                   by Vincent Guitard

$(tput setaf $borderColor)$borderLine$(tput sgr0)
EOF
}

MainMenu()
{
    dontClear=0
    dontPrintLogo=0

    while : ; do

        if [ $dontClear -eq 0 ] ; then
            clear
        else
            dontClear=0
        fi
        if [ $dontPrintLogo -eq 0 ] ; then
            echo
            MainLogo
        else
            dontPrintLogo=0
        fi

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
        echo "$prefix!$(tput setaf $menuTitleColor)                                  Main Menu                                  $(tput setaf $menuBorderColor)!"
        echo "$prefix+-----+----------+------------------------------------------------------------+"
        echo "$prefix!$(tput setaf $menuLabelColor) Nbr $(tput setaf $menuBorderColor)!$(tput setaf $menuLabelColor) Choice $(tput setaf $menuBorderColor)  !$(tput setaf $menuLabelColor) Detail   $(tput setaf $menuBorderColor)                                                  !"
        echo "$prefix+-----+----------+------------------------------------------------------------+"
        echo "$prefix!$(tput setaf $menuItemNumberColor)  1  $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) METAR    $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Retrieve METeorological Aerodrome Reports by location      $(tput setaf $menuBorderColor)!"
        echo "$prefix+-----+----------+------------------------------------------------------------+"
        echo "$prefix!$(tput setaf $menuItemNumberColor)  2  $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) NOTAM   $(tput setaf $menuBorderColor) !$(tput setaf $menuItemColor) Retrieve NOtice(s) to AirMen by location                   $(tput setaf $menuBorderColor)!"
        echo "$prefix+-----+----------+------------------------------------------------------------+"
        echo "$prefix!$(tput setaf $menuItemNumberColor)  q  $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Quit     $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Quit to terminal                                           $(tput setaf $menuBorderColor)!"
        echo "$prefix+-----+----------+------------------------------------------------------------+"
        echo
        printf "$(tput setaf $menuQueryColor)$choicePrefix""Choice number: "
        tput setaf $menuChoiceColor
        read menuChoice
        tput sgr0

        case $menuChoice in
            1) SendToMetar ;;
            2) SendToNotam ;;
            q | Q) echo ; exit 0 ;;
            *) tput setaf $warningMessage ; echo ; echo "$choicePrefix""Unrecognised option" ; tput sgr0 ; dontClear=1 ; dontPrintLogo=1 ;;
        esac
    done
}

SendToMetar()
{
    clear
    MainLogo
    $SCRIPT_DIR/metar/metar.sh --interactive

    if [ -a $SCRIPT_DIR/metar/.quit ] ; then
        rm $SCRIPT_DIR/metar/.quit
        exit 0
    fi
}

SendToNotam()
{
    clear
    MainLogo
    $SCRIPT_DIR/notam/notamRetriever.sh --interactive

    if [ -a $SCRIPT_DIR/notam/.quit ] ; then
        rm $SCRIPT_DIR/notam/.quit
        exit 0
    fi
}

TempFileClearing()
{
    tput setaf $warningMessage
    echo
    echo "$choicePrefix""The application wasn't cleanly closed."
    echo "Clearing temporary files . . ."
    tput sgr0
    rm "$1"
    sleep 2
}

if [ -a $SCRIPT_DIR/metar/.quit ] ; then
    TempFileClearing "$SCRIPT_DIR/metar/.quit"
fi
if [ -a $SCRIPT_DIR/notam/.quit ] ; then
    TempFileClearing "$SCRIPT_DIR/notam/.quit"
fi

MainMenu

exit 0
