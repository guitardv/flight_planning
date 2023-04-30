
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

########
# Variable declaration
########

# Working directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

## COLORS

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

## generate prefixes to center logos and menu in the terminal

# Width of the terminal
COLUMNS=$(tput cols)
ColumnsUsedForCalcul="$COLUMNS" #that one is a fixed value and will be used to check if the window size changed

# logo
banner_width=79
logoIndent=$(( (COLUMNS - banner_width) / 2 ))
borderIndent=$(( logoIndent / 2 ))
borderLength=$(( COLUMNS - logoIndent ))
borderLine=''
logoPrefix=''
for ((i=1; i<=logoIndent; i++)) ; do
    logoPrefix+=' '
    if [ $i -le $borderIndent ] ; then
        borderLine+=' '
    fi
done

for ((i=1; i<=borderLength; i++)) ; do
    borderLine+='='
done

# menu
menuWidth=79
menuIndent=$(( (COLUMNS - menuWidth) / 2 ))
choiceIndent=$(( menuIndent / 2 ))
menuPrefix=''
choicePrefix=''
for ((i=1; i<=menuIndent; i++)) ; do
    menuPrefix+=' '
    if [ $i -le $choiceIndent ] ; then
        choicePrefix+=' '
    fi
done

# To determine if the terminal width is sufficient minWindowWidth is defined as the larger value between banner_width and menuWidth
if [ $banner_width -lt $menuWidth ] ; then
    minWindowWidth=$menuWidth
else
    minWindowWidth=$banner_width
fi

MainLogo()
{

    # If the size of the terminal changed, recalculate the position of the logo and menu
    if [ "$ColumnsUsedForCalcul" != "$COLUMNS" ] ; then
        RecalculateWindowSize
    fi

    # ASCII text generated with: https://patorjk.com/software/taag/#p=display&h=1&v=0&f=Slant&t=Flight%20Planner
    # Font: Slant, Character width: Fitted, Character Height: Full
    cat << EOF
$(tput setaf $borderColor)$borderLine$(tput setaf $logoColor)
$logoPrefix    ______ __ _         __     __     ____   __                                
$logoPrefix   / ____// /(_)____ _ / /_   / /_   / __ \ / /____ _ ____   ____   ___   _____
$logoPrefix  / /_   / // // __ \`// __ \ / __/  / /_/ // // __ \`// __ \ / __ \ / _ \ / ___/
$logoPrefix / __/  / // // /_/ // / / // /_   / ____// // /_/ // / / // / / //  __// /    
$logoPrefix/_/    /_//_/ \__, //_/ /_/ \__/  /_/    /_/ \__,_//_/ /_//_/ /_/ \___//_/     
$logoPrefix             /____/                                                            
$logoPrefix $(tput setaf $copyrightColor)                   by Vincent Guitard

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

        # If the size of the terminal changed, recalculate the position of the logo and menu
        if [ "$ColumnsUsedForCalcul" != "$COLUMNS" ] ; then
            RecalculateWindowSize
        fi

        # If the terminal width is too small, print a warning message
        if [ $COLUMNS -lt $minWindowWidth ] && [ ! -f "$SCRIPT_DIR/.conf.d/noSmallWindowWarning" ] ; then
            tput setaf $warningMessage
            echo
            echo "$choicePrefix""It seems that you are running this software in a small window."
            echo "$choicePrefix""Your current window width is $COLUMNS columns. For your convenience, a minimum width of $minWindowWidth columns is advised."
            tput sgr0
            echo
            printf "$choicePrefix""If you wish to permanently disable this warning, press Y. Else, press Enter to continue. "
            read -n 1 warningChoice
            echo
            if [ "$warningChoice" == "y" ] || [ "$warningChoice" == "Y" ] ; then
                if [ ! -d "$SCRIPT_DIR/.conf.d" ] ; then
                    mkdir "$SCRIPT_DIR/.conf.d"
                fi
                touch "$SCRIPT_DIR/.conf.d/noSmallWindowWarning"
                echo "$choicePrefix""This warning won't be displayed anymore. You can restore it using the configuration utility."
            else
                echo "$choicePrefix""Proceeding to main menu."
            fi
        fi

        echo
        echo
        echo "$(tput setaf $menuBorderColor)$menuPrefix+-----------------------------------------------------------------------------+"
        echo "$menuPrefix!$(tput setaf $menuTitleColor)                                  Main Menu                                  $(tput setaf $menuBorderColor)!"
        echo "$menuPrefix+-----+----------+------------------------------------------------------------+"
        echo "$menuPrefix!$(tput setaf $menuLabelColor) Nbr $(tput setaf $menuBorderColor)!$(tput setaf $menuLabelColor) Choice $(tput setaf $menuBorderColor)  !$(tput setaf $menuLabelColor) Detail   $(tput setaf $menuBorderColor)                                                  !"
        echo "$menuPrefix+-----+----------+------------------------------------------------------------+"
        echo "$menuPrefix!$(tput setaf $menuItemNumberColor)  1  $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) METAR    $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Retrieve METeorological Aerodrome Reports by location      $(tput setaf $menuBorderColor)!"
        echo "$menuPrefix+-----+----------+------------------------------------------------------------+"
        echo "$menuPrefix!$(tput setaf $menuItemNumberColor)  2  $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) NOTAM   $(tput setaf $menuBorderColor) !$(tput setaf $menuItemColor) Retrieve NOtice(s) to AirMen by location                   $(tput setaf $menuBorderColor)!"
        echo "$menuPrefix+-----+----------+------------------------------------------------------------+"
        echo "$menuPrefix!$(tput setaf $menuItemNumberColor)  c  $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Config  $(tput setaf $menuBorderColor) !$(tput setaf $menuItemColor) Start the configuration utility                            $(tput setaf $menuBorderColor)!"
        echo "$menuPrefix+-----+----------+------------------------------------------------------------+"
        echo "$menuPrefix!$(tput setaf $menuItemNumberColor)  q  $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Quit     $(tput setaf $menuBorderColor)!$(tput setaf $menuItemColor) Quit to terminal                                           $(tput setaf $menuBorderColor)!"
        echo "$menuPrefix+-----+----------+------------------------------------------------------------+"
        echo
        printf "$(tput setaf $menuQueryColor)$choicePrefix""Choice number: "
        tput setaf $menuChoiceColor
        read menuChoice
        tput sgr0

        case $menuChoice in
            1) SendToMetar ;;
            2) SendToNotam ;;
            c | C) MainConfig --interactive ;;
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

    if [ -f "$SCRIPT_DIR/metar/.quit" ] ; then
        rm "$SCRIPT_DIR/metar/.quit"
        exit 0
    fi
}

SendToNotam()
{
    clear
    MainLogo
    $SCRIPT_DIR/notam/notamRetriever.sh --interactive

    if [ -f "$SCRIPT_DIR/notam/.quit" ] ; then
        rm "$SCRIPT_DIR/notam/.quit"
        exit 0
    fi
}

RecalculateWindowSize()
{
    ## generate prefixes to center logos and menu in the terminal

    # Width of the terminal
    COLUMNS=$(tput cols)
    ColumnsUsedForCalcul="$COLUMNS" #that one is a fixed value and will be used to check if the window size changed

    # logo
    banner_width=79
    logoIndent=$(( (COLUMNS - banner_width) / 2 ))
    borderIndent=$(( logoIndent / 2 ))
    borderLength=$(( COLUMNS - logoIndent ))
    borderLine=''
    logoPrefix=''
    for ((i=1; i<=logoIndent; i++)) ; do
        logoPrefix+=' '
        if [ $i -le $borderIndent ] ; then
            borderLine+=' '
        fi
    done

    for ((i=1; i<=borderLength; i++)) ; do
        borderLine+='='
    done

    # menu
    menuWidth=79
    menuIndent=$(( (COLUMNS - menuWidth) / 2 ))
    choiceIndent=$(( menuIndent / 2 ))
    menuPrefix=''
    choicePrefix=''
    for ((i=1; i<=menuIndent; i++)) ; do
        menuPrefix+=' '
        if [ $i -le $choiceIndent ] ; then
            choicePrefix+=' '
        fi
    done
}

MainConfig()
{
    if [ "$1" == "--initial" ] ; then
        clear
        MainLogo
        echo
        tput setaf $warningMessage
        echo "$choicePrefix""notam/SECRET subfolder not detected, is this the first time you run this software ?"
        tput sgr0
        echo "$choicePrefix""Starting initial configuration."
    elif [ "$1" == "--commandline" ] ; then
        clear
        MainLogo
    elif [ "$1" == "--interactive" ] ; then
        clear
        MainLogo
    fi

    echo
    echo "$choicePrefix""Welcome to the flight_planning configuration utility."
    echo
    echo "$choicePrefix""Configuration of the \"print\" module."

    # if the config directory for print already exists
    if [ -d "$SCRIPT_DIR/print/SECRET" ] ; then
        # if the directory isn't empty
        if [ "$(ls -A $SCRIPT_DIR/print/SECRET)" ] ; then
            tput setaf $menuQueryColor
            printf "$choicePrefix""The folder $SCRIPT_DIR/print/SECRET isn't empty. Do you want to overwrite its content ? (y/N) "
            tput setaf $menuChoiceColor
            read overWrite
            tput sgr0
            # default is No
            if [ "$overWrite" == "" ] ; then overWrite='n' ; fi
            case $overWrite in
                y | Y) configChoice='y' ; echo ;;
                n | N) configChoice='n' ; echo ;;
                *) tput setaf $warningMessage ; echo ; echo "$choicePrefix""Unrecognised choice" ; tput sgr0 ; MainConfig ; exit 0 ;;
            esac
            if [ "$overWrite" == "y" ] ; then
                rm -r "$SCRIPT_DIR/print/SECRET"
            elif [ "$overWrite" == "n" ] ; then
                echo "$choicePrefix""Skipping configuration of the remote printing feature."
            else
                tput setaf $warningMessage
                echo "$choicePrefix""Unexpected error."
                echo "$choicePrefix""ERROR: Unable to handle choice: $overWrite"
                tput sgr0
                echo
                exit 1
            fi
        else # if the directory is empty
            rmdir "$SCRIPT_DIR/print/SECRET"
        fi
    fi

    # config of remote printing
    if [ ! -d "$SCRIPT_DIR/print/SECRET" ] ; then
        echo "$choicePrefix""Configuration of the remote printing feature."
        tput setaf $menuQueryColor
        printf "$choicePrefix""Is this installation located on the remote Printer or on the Client (p/C): "
        tput setaf $menuChoiceColor
        read configChoice
        tput sgr0

        # default is client
        if [ "$configChoice" == "" ] ; then configChoice='c' ; fi

        case $configChoice in
            p | P) configChoice='p' ; echo ;;
            c | C) configChoice='c' ; echo ;;
            *) tput setaf $warningMessage ; echo ; echo "$choicePrefix""Unrecognised choice" ; tput sgr0 ; MainConfig ; exit 0 ;;
        esac

        mkdir "$SCRIPT_DIR/print/SECRET"

        if [ "$configChoice" == "p" ] ; then
            echo "$choicePrefix""Done"
        elif [ "$configChoice" == "c" ] ; then
            echo
            tput setaf $menuQueryColor
            printf "$choicePrefix""Please, specify the IP of the remote device connected to the printer: "
            tput setaf $menuChoiceColor
            read printerIP
            tput setaf $menuQueryColor
            printf "$choicePrefix""Please, specify the name of the account you wish the software to use on the remote device to use the printer: "
            tput setaf $menuChoiceColor
            read accountName
            tput setaf $menuQueryColor
            printf "$choicePrefix""Please, specify the PATH to the repo root folder for the session$(tput setaf $menuChoiceColor) $accountName@$printerIP$(tput setaf $menuQueryColor) (without '/' at the end): "
            tput setaf $menuChoiceColor
            read repoPATH
            tput sgr0
            echo "$choicePrefix""Generating the configuration files."
            echo "$printerIP" > $SCRIPT_DIR/print/SECRET/printer_ip
            echo "$accountName" > $SCRIPT_DIR/print/SECRET/user_id
            echo "$repoPATH" > $SCRIPT_DIR/print/SECRET/repo_path
            echo "$choicePrefix""Done"
        else
            tput setaf $warningMessage
            echo "$choicePrefix""Unexpected error."
            echo "$choicePrefix""ERROR: Unable to handle choice: $configChoice"
            tput sgr0
            echo
            exit 1
        fi
    fi

    echo
    echo "$choicePrefix""Configuration of the \"notam\" module."

    # if the config directory for notam already exists
    if [ -d "$SCRIPT_DIR/notam/SECRET" ] ; then
        # if the directory isn't empty
        if [ "$(ls -A $SCRIPT_DIR/notam/SECRET)" ] ; then
            tput setaf $menuQueryColor
            printf "$choicePrefix""The folder $SCRIPT_DIR/notam/SECRET isn't empty. Do you want to overwrite its content ? (y/N) "
            tput setaf $menuChoiceColor
            read overWrite
            tput sgr0
            # default is No
            if [ "$overWrite" == "" ] ; then overWrite='n' ; fi
            case $overWrite in
                y | Y) configChoice='y' ; echo ;;
                n | N) configChoice='n' ; echo ;;
                *) tput setaf $warningMessage ; echo ; echo "$choicePrefix""Unrecognised choice" ; tput sgr0 ; MainConfig ; exit 0 ;;
            esac
            if [ "$overWrite" == "y" ] ; then
                rm -r "$SCRIPT_DIR/notam/SECRET"
            elif [ "$overWrite" == "n" ] ; then
                echo "$choicePrefix""Skipping configuration of the NOTAM retrieval feature."
            else
                tput setaf $warningMessage
                echo "$choicePrefix""Unexpected error."
                echo "$choicePrefix""ERROR: Unable to handle choice: $overWrite"
                tput sgr0
                echo
                exit 1
            fi
        else # if the directory is empty
            rmdir "$SCRIPT_DIR/notam/SECRET"
        fi
    fi

    # config of NOTAM retrieval
    if [ ! -d $SCRIPT_DIR/notam/SECRET ] ; then
        echo "$choicePrefix""Configuration of the NOTAM retrieval feature."

        mkdir $SCRIPT_DIR/notam/SECRET

        echo
        tput setaf $menuQueryColor
        printf "$choicePrefix""Please, specify your Client ID for the FAA NOTAM API: "
        tput setaf $menuChoiceColor
        read clientID
        tput setaf $menuQueryColor
        printf "$choicePrefix""Please, specify your API Key for the FAA NOTAM API: "
        tput setaf $menuChoiceColor
        read apiKey
        tput sgr0
        echo "$choicePrefix""Generating the configuration files."
        echo "$clientID" > $SCRIPT_DIR/notam/SECRET/api_client_id
        echo "$apiKey" > $SCRIPT_DIR/notam/SECRET/api_client_secret
        echo "$choicePrefix""Done"
    fi

    # User config
    if [ -d "$SCRIPT_DIR/.conf.d" ] && [ "$(ls -A $SCRIPT_DIR/.conf.d)" ] ; then
        echo
        echo "$choicePrefix""User configuration files detected in $SCRIPT_DIR/.conf.d"
        tput setaf $menuQueryColor
        printf "$choicePrefix""Do you wish to clear user configurations and return the software to its default settings (FAA NOTAM API and remote printer SSH informations won't be affected) ? (y/N) "
        tput setaf $menuChoiceColor
        read resetConfigToDefault
        tput sgr0
        echo
        if [ "$resetConfigToDefault" == "y" ] || [ "$resetConfigToDefault" == "Y" ] ; then
            rm $SCRIPT_DIR/.conf.d/*
            echo "$choicePrefix""Done"
        elif [ "$resetConfigToDefault" == "n" ] || [ "$resetConfigToDefault" == "N" ] || [ "$resetConfigToDefault" == "" ] ; then
            echo "Ignoring user settings."
        else
            tput setaf $warningMessage
            echo "$choicePrefix""Unexpected error."
            echo "$choicePrefix""ERROR: Unable to handle choice: $resetConfigToDefault"
            tput sgr0
            echo
            exit 1
        fi
        echo
        echo "$choicePrefix""No user configuration file found in $SCRIPT_DIR/.conf.d"
        echo "$choicePrefix""Nothing to do."
        echo
    fi

    echo
    echo "$choicePrefix""Configuration complete, you can now use the software."
    echo "$choicePrefix""If you wish to change the configurations, you can run the command \"$(basename $0) --config\" to come back to this utility."
    read -s -n 1 -p "$choicePrefix""Press any key to continue to main menu."
    echo
}

TempFileClearing()
{
    tput setaf $warningMessage
    echo
    echo "$choicePrefix""The application wasn't closed cleanly."
    echo "$choicePrefix""Clearing temporary files . . ."
    tput sgr0
    rm "$1"
    sleep 2
}

# Check if the script is run for the first time by checking if the SECRET subfolder has been created in the notam module folder
if [ ! -d "$SCRIPT_DIR/notam/SECRET" ] ; then
    MainConfig --initial
fi

# Check the presence of temp files
if [ -f "$SCRIPT_DIR/metar/.quit" ] ; then
    TempFileClearing "$SCRIPT_DIR/metar/.quit"
fi
if [ -f "$SCRIPT_DIR/notam/.quit" ] ; then
    TempFileClearing "$SCRIPT_DIR/notam/.quit"
fi

if [ "$1" == "--config" ] ; then
    MainConfig --commandline
fi

MainMenu

exit 0
