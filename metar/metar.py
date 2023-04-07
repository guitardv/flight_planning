#!/usr/bin/env python3

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

# version 1.1
# import metar from designated canadian airports (default: CYHU) and print them in the standard output

import sys
import os
import re
import time
from bs4 import BeautifulSoup
from urllib.request import urlopen

metarURL = "https://flightplanning.navcanada.ca/cgi-bin/Fore-obs/metar.cgi?NoSession=NS_Inconnu&format=raw&Langue=anglais&Region=can&Stations="
DefaultAirport = "CYHU"
argvLen = len(sys.argv)

# for the program to stay open in the terminal and refresh
# the METAR every minute instead of printing the METAR once and closing,
# use the argument -l or --looped, udvLooped will be set to 1
udvLooped = 2

if(argvLen == 1):
    metarURL = metarURL+DefaultAirport
elif(argvLen > 1):
    if("-l" in sys.argv or "--looped" in sys.argv):
        udvLooped = 1
        if(argvLen == 2):
            metarURL = metarURL+DefaultAirport
    if(sys.argv[1] != "-l" and sys.argv[1] != "--looped"):
        metarURL = metarURL + sys.argv[1]
    if(argvLen>2):
        for i in range(2, argvLen):
            if(sys.argv[i] != "-l" and sys.argv[i] != "--looped"):
                metarURL = metarURL + "," + sys.argv[i]
else:
    sys.exit("Invalid argument length.")

del argvLen


while(udvLooped):
    if(udvLooped == 2):
        udvLooped = 0

    metarWebPage = BeautifulSoup(urlopen(metarURL).read().decode("ISO-8859-1"), "lxml")
    metarWebPageText = metarWebPage.get_text().splitlines()

    listOfLinesToRemove = []


    for i in range(len(metarWebPageText)):
        if(metarWebPageText[i] == '' or metarWebPageText[i] == ' '):
            listOfLinesToRemove.append(i)
    if(len(listOfLinesToRemove)>0):
        for i in range(len(listOfLinesToRemove)-1,-1,-1):
            del metarWebPageText[listOfLinesToRemove[i]]
    del listOfLinesToRemove


    ###############
    ## Formatage ##
    ###############

    metarWebPageText[-2] = re.sub(r'\s+',' ',metarWebPageText[-2] + metarWebPageText[-1])
    del metarWebPageText[-1], metarWebPageText[-7:-2]
    metarWebPageText[-2] = ''


    if(metarWebPageText[1] == "Your browser does not support iframe, click here to view AWWS News."):
        metarWebPageText[1] = ''
    elif(metarWebPageText[0] == " AWWS - Forecasts and Observations " and metarWebPageText[1] != ''):
        metarWebPageText.insert(1,'')

    if(metarWebPageText[3] == "  METAR/TAF " and metarWebPageText[2] != ''):
        metarWebPageText.insert(3,'')
    if(metarWebPageText[4] == "  METAR/TAF " and metarWebPageText[5] != ''):
        metarWebPageText.insert(5,'')

    i=0
    while i < len(metarWebPageText):
        if(metarWebPageText[i].split(' ')[0] == "TAF"):
            metarWebPageText.insert(i,'')
            i=i+1
        elif(len(metarWebPageText[i].split(' '))>1):
            if(metarWebPageText[i].split(' ')[0] == "RMK" and (metarWebPageText[i].split(' ')[1] == "FCST" or metarWebPageText[i].split(' ')[1] == "NXT")):
                metarWebPageText.insert(i+1,'')
                i=i+1
            elif(len(metarWebPageText)>3):
                if(metarWebPageText[i].split(' ')[1] == "-" and metarWebPageText[i].split(' ')[2] == "No" and metarWebPageText[i].split(' ')[3] == "TAF"):
                    metarWebPageText.insert(i+1,'')
                    i=i+1
        i=i+1
    del i


    # Fin formatage
    #############


    if(udvLooped):
        os.system("clear")
        print('\n'.join(metarWebPageText))
        time.sleep(60)
    else:
        print('\n','\n'.join(metarWebPageText),'\n')

sys.exit(0)

#si je veux ecrire le metar
MetarFilePath = "lastImportedMetar.txt"
with open(MetarFilePath, "w") as metarFile:
    metarFile.write('\n'.join(metarWebPageText))
