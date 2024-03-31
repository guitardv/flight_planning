#!/usr/bin/env python3

##############################################################################
# Copyright 2024 Vincent Guitard
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

# version 1.3.1
# import metar from designated airports (default: CYHU) and print them in the standard output

# changes
# v 1.3.2
# corrected the bug where one metar was missing at the time a new one was issued
# v 1.3.1
# exception handling for the AWC api request.
# simplification of the api response processing: I no longer need to use beautifulsoup since the AWC api return raw text.
# v 1.3
# switching the source of meteorological information from the commercial metar-taf.com to US Gov NOAA Aviation Weather Center API (https://aviationweather.gov/data/api/#/Data/dataMetars)
# v 1.2
# AWWS (flightplanning.navcanada.ca) was decommissioned by NAV CANADA on 2024-02-28 in favor of CFPS (plan.navcanada.ca/wxrecall/), so the version 1.1 and earlier this script don't work anymore
#  weather information source was changed to metar-taf.com

import sys
import os
import time
from urllib.request import urlopen
from os.path import exists
from datetime import datetime, timezone

DefaultAirport = "CYHU".upper()
includeTAF = "true"
# the .12 is added because otherwise the metar from ageOfEarliestMetarMessageToBeReported hours ago is removed before the new one is published
ageOfEarliestMetarMessageToBeReported = "3.12"
retryIfRequestFail = 3
#time in seconds, the number of current retry is added to this value so for the first retry (retry 0), no time will be added, for retry 1, 1s will be added, for retry 2, 2s etc...
timeBetweenRetry = 1
metarURL = "https://aviationweather.gov/api/data/metar.php?format=raw&order=ids%2C-obs&sep=true&taf=" + includeTAF + "&hours=" + ageOfEarliestMetarMessageToBeReported + "&ids="
argvLen = len(sys.argv)
stationICAOlist = []

# for the program to stay open in the terminal and refresh
# the METAR every minute instead of printing the METAR once and closing,
# use the argument -l or --looped, udvLooped will be set to 1
udvLooped = 2

if(argvLen == 1):
    metarURL = metarURL+DefaultAirport
    stationICAOlist.append(DefaultAirport)
elif(argvLen > 1):
    if("-l" in sys.argv or "--looped" in sys.argv):
        udvLooped = 1
        if(argvLen == 2):
            metarURL = metarURL+DefaultAirport
            stationICAOlist.append(DefaultAirport)
    if(sys.argv[1] != "-l" and sys.argv[1] != "--looped" and metarURL[-1:] == '='):
        metarURL = metarURL + sys.argv[1].upper()
        stationICAOlist.append(sys.argv[1].upper())
    if(argvLen>2):
        for i in range(2, argvLen):
            if(sys.argv[i] != "-l" and sys.argv[i] != "--looped"):
                metarURL = metarURL + "," + sys.argv[i].upper()
                stationICAOlist.append(sys.argv[i].upper())
else:
    sys.exit("Invalid argument length.")

del argvLen


while(udvLooped):
    if(udvLooped == 2):
        udvLooped = 0

    # if the script is running on the RPi
    if(os.path.exists("/sys/class/backlight/10-0045/bl_power")):
        with open("/sys/class/backlight/10-0045/bl_power", 'r') as backlight_power:
            # If the display is turned off, don't go further and check the display power status every minute
            while(backlight_power.read() == '1'):
                time.sleep(60)

    # if the initial request to the api fail (html status code != 200), the request will be tried again retryIfRequestFail time with a pause of
    # timeBetweenRetry+<number of retry> second(s) between each retry
    for i in range(retryIfRequestFail+1):
        try:
            metarWebPage = urlopen(metarURL)
        except Exception as e:
            if(i == retryIfRequestFail):
                print("\nError: API request failed with exception " + str(e) + ".\n\n   Maximum number of retry reached.\n")
                sys.exit(1)
            else:
                print("\nError: API request failed with exception " + str(e) + ".\n")
                time.sleep(timeBetweenRetry+i)
                print("   Trying again.\n")
                continue
        else:
            if(metarWebPage.getcode() == 200):
                metarWebPageText = metarWebPage.read().decode("UTF-8").splitlines()
                break
            else:
                if(i == retryIfRequestFail):
                    print("\nError: API request failed with HTML status code " + str(metarWebPage.getcode()) + ".\n\n   Maximum number of retry reached.\n")
                    sys.exit(1)
                else:
                    print("\nError: API request failed with HTML status code " + str(metarWebPage.getcode()) + ".\n")
                    time.sleep(timeBetweenRetry+i)
                    print("   Trying again.\n")

 
    ###############
    ## Formatage ##
    ###############

    # header
    metarWebPageText.insert(0, "AWC - Forecasts and Observations")
    metarWebPageText.insert(1, '')
    metarWebPageText.insert(2, datetime.now(timezone.utc).strftime("Request generated at %Y-%m-%d %H:%M %Z."))
    metarWebPageText.insert(3,'')

    if(includeTAF == "true"):
        metarWebPageText.insert(4,"METAR/TAF")
    else:
        metarWebPageText.insert(4,"METAR")

    metarWebPageText.insert(5,'')
    metarWebPageText.insert(6,"METAR/SPECI " + stationICAOlist[0])

    # METAR/TAF go there

    # If there's more than one stations in the report, add the "METAR/SPECI <ICAO>" header above all metar/speci message groups
    # Add an indentation before all METAR/SPECI messages
    stationQt = len(stationICAOlist)
    headerLinesToAdd = []
    emptyLineInText = 0
    # the range start at 7 because the last line inserted is number 6
    for i in range(7,len(metarWebPageText)):
        if(metarWebPageText[i] == ''):
            emptyLineInText = emptyLineInText + 1
            if(emptyLineInText == 2):
                # if after the metar/taf of one station
                emptyLineInText = 0
                headerLinesToAdd.insert(0,i)
                stationQt = stationQt - 1
            elif(stationQt <= 1 and emptyLineInText == 1):
                # if after the last metar/speci but before the last taf
                break
        else:
            if(emptyLineInText == 0):
                # if current line is a metar/speci message
                metarWebPageText[i] = "  " + metarWebPageText[i]
    del emptyLineInText
    del stationQt
    if(len(headerLinesToAdd) > 0):
        # If there's more than one stations in the report, add the "METAR/SPECI <ICAO>" header above all metar/speci message groups
        for i in range(len(headerLinesToAdd)):
            metarWebPageText.insert(headerLinesToAdd[i]+1,"METAR/SPECI " + stationICAOlist[-(i+1)])
    del headerLinesToAdd

    # footer
    metarWebPageText.insert(len(metarWebPageText),'')
    metarWebPageText.insert(len(metarWebPageText),"Weather data provided by the US Aviation Weather Center")


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