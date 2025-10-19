#!/usr/bin/env python3

##############################################################################
# Copyright 2024-2025 Vincent Guitard
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

# version 1.3.5
# import metar from designated airports (default: LFMT) and print them in the standard output

# changes
# v 1.3.5
# As of September 25 2025, aviationweather.gov's API went back to sending metar reports grouped by icao and accompanied by only the latest taf.
# Query parameter "order" was not restored, so the sorting block of code writen for v1.3.4 is kept but the rest is essentially rolled back.
# Changed default airport to LFMT.
# v 1.3.4
# As of September 2025, aviationweather.gov changed API. The new one restore support of decimals for the "hours" parameter, is querried at a slightly different address, and for each airfield id returns as many METAR/SPECI + TAF pairs as their are METARS/SPECI fitting the "hours" parameter instead of all the METARS/SPECI followed by the latest TAF. Query parameter "order" was removed, when the script query multiple stations reports are now sorted by time in the API answer.
# ageOfEarliestMetarMessageToBeReported is a float again and is restored to its previous default value of 3.12
# ageOfEarliestMetarMessageToBeReported will now be printed alongside the time of request generation for clarity and traceability
# the query address is changed from https://aviationweather.gov/api/data/metar.php? to https://aviationweather.gov/api/data/metar?
# unsupported "order" parameter was removed from the query
# API answer is formated so that all the METAR/SPECI for a given airfield are grouped together above the latest TAF for that airfield, all other TAFs are discarded
# bugfix for when the script is set to run on loop on the RPi and the display is turned off
# sorting of the metar/taf blocks in the same order as in the query
# v 1.3.3
# As of october 2024, aviationweather.gov's API no longer support decimal for the "hours" parameter.
# ageOfEarliestMetarMessageToBeReported is now an integer, a function will count the METAR lines received in answer and renew the request with a +1 if one is missing.
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

DefaultAirport = "LFMT".upper()
includeTAF = "true"
# the .12 is added because otherwise the metar from ageOfEarliestMetarMessageToBeReported hours ago is removed before the new one is published
ageOfEarliestMetarMessageToBeReported = "3.12"
retryIfRequestFail = 3
#time in seconds, the number of current retry is added to this value so for the first retry (retry 0), no time will be added, for retry 1, 1s will be added, for retry 2, 2s etc...
timeBetweenRetry = 1
metarURL = "https://aviationweather.gov/api/data/metar?format=raw&order=ids%2C-obs&sep=true&taf=" + includeTAF + "&hours=" + ageOfEarliestMetarMessageToBeReported + "&ids="
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

    # if the script is running as a loop on the RPi
    if(os.path.exists("/sys/class/backlight/10-0045/bl_power") and udvLooped != 0):
        backlight_is_off = 1
        while(backlight_is_off):
            with open("/sys/class/backlight/10-0045/bl_power", 'r') as backlight_power:
                # If the display is turned off, don't go further and check the display power status every minute
                if(backlight_power.read() == "1\n"):
                    time.sleep(60)
                else:
                    backlight_is_off = 0
        del backlight_is_off

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
    metarWebPageText.insert(0,"AWC - Forecasts and Observations")
    metarWebPageText.insert(1,'')
    metarWebPageText.insert(2,datetime.now(timezone.utc).strftime("Request generated at %Y-%m-%d %H:%M %Z."))
    metarWebPageText.insert(3,"Printing weather observations reported in the last " + ageOfEarliestMetarMessageToBeReported + " hours.")
    metarWebPageText.insert(4,'')

    # Here is where the warning goes if one or more of the requested icao aren't in the api answer

    if(includeTAF == "true"):
        metarWebPageText.insert(5,"METAR/TAF")
    else:
        metarWebPageText.insert(5,"METAR")

    metarWebPageText.insert(6,'')
#    metarWebPageText.insert(7,"METAR/SPECI " + stationICAOlist[0])

    # METAR/TAF go there

    # If there's more than one stations in the report, add the "METAR/SPECI <ICAO>" header above all metar/speci message groups
    # Add an indentation before all METAR/SPECI messages


    # block commented on v1.3.4
    # it worked when returnedICAO = []the metar tafs were sorted by station and only the most recent taf was sent but not with the new api
    # and uncommented on v1.3.5 when the api started sending metar tafs sorted by station with only the most recent taf again
    stationQt = len(stationICAOlist)
    returnedICAO = []
    currentICAO = ""
    headerLinesToAdd = []
    emptyLineNumber = 0
    reportBodyStart = 7
    # the range start at 7 because the last line inserted is number 6
    for i in range(reportBodyStart,len(metarWebPageText)):
        if(metarWebPageText[i] == ''):
            emptyLineNumber = emptyLineNumber + 1
            if(emptyLineNumber == 2):
                # if after the metar/taf of one station
                emptyLineNumber = 0
                currentICAO = ""
            elif(stationQt < 1 and emptyLineNumber == 1):
                # if after the last metar/speci but before the last taf
                break
        else:
            if(emptyLineNumber == 0):
                # if current line is a metar/speci message
                metarWebPageText[i] = "  " + metarWebPageText[i]
                # if the METAR/SPECI header hasn't been added yet
                if(currentICAO == ""):
                    headerLinesToAdd.insert(0,i)
                    currentICAO = metarWebPageText[i].split()[1]
                    returnedICAO.insert(len(returnedICAO),currentICAO)
                    stationQt = stationQt - 1

                
    currentICAO = ""
    del stationQt
    del emptyLineNumber
    if(len(headerLinesToAdd) > 0):
        # If there's more than one stations in the report, add the "METAR/SPECI <ICAO>" header above all metar/speci message groups
        for i in range(len(headerLinesToAdd)):
            metarWebPageText.insert(headerLinesToAdd[i],"METAR/SPECI " + list(reversed(returnedICAO))[i])
    del headerLinesToAdd

    # block commented with v1.3.5
    # the api went back to sending the metar taf sorted by station with only the most recent taf so I don't need all that anymore
    """
    stationQt = len(stationICAOlist)
    currentICAO = ""
    metarParserState = 0
    reportBodyStart = 7
    # the range start at 7 because the last line inserted is number 6
    for i in range(reportBodyStart,len(metarWebPageText)):
        if(metarWebPageText[i] == ''):
            metarParserState = metarParserState + 1
            if(metarParserState == 3):
                # if after the metar/taf of one station
                metarParserState = 0
                stationQt = stationQt - 1
        elif(metarParserState == 0):
            metarParserState = 1
            # if current line is a metar/speci message
            currentICAO = metarWebPageText[i].split()[1]
            if(currentICAO in stationICAOlist):
                # add the indent for current METAR/SPECI
                metarWebPageText[i] = "  " + metarWebPageText[i]
                metarLineAdded = 0
                # parse the api answer from the bottom
                for c in range(len(metarWebPageText)-1,i+1,-1):
                    if(metarWebPageText[c] != ''):
                        # if the line is a metar/speci of the current ICAO station, move the line to just bellow the first one
                        if(metarWebPageText[c].split()[0] == "METAR" or metarWebPageText[c].split()[0] == "SPECI"):
                            if(metarWebPageText[c].split()[1] == currentICAO):
                                metarLineAdded = metarLineAdded + 1
                                metarWebPageText.insert(i+1,"  " + metarWebPageText[c])
                                del metarWebPageText[c+1]
                                # removing the empty line above the METAR
                                del metarWebPageText[c]
                        elif(metarWebPageText[c].split()[0] == "TAF" and (metarWebPageText[c].split()[1] == currentICAO or (metarWebPageText[c].split()[1] == "AMD" and metarWebPageText[c].split()[2] == currentICAO))):
                            # i + metarLineAdded + 2 is the line of the latest TAF for the current ICAO, if c is greater than that, then it's pointing to an older TAF that must be removed
                            if(c > i + metarLineAdded + 2):
                                while(c < len(metarWebPageText)):
                                    if(metarWebPageText[c] != ''):
                                        del metarWebPageText[c]
                                    else:
                                        break
                                # removing the blank line before the TAF
                                del metarWebPageText[c-1]
                            # if we have reached the latest taf, all the lines above are already formated
                            else:
                                break
                    # if the next loop (c-1) will reach one of the METARs I added (i+metarLineAdded), break the loop to avoid messing their order
                    # that break should never be tripped as the one for the latest TAF should be triggered just before but I still add it for safety
                    if(i+metarLineAdded == c-1):
                        break
                del metarLineAdded
                # add METAR/SPECI header
                metarWebPageText.insert(i,"METAR/SPECI " + currentICAO)
                
                # if the formated station was the last one, no need to parse the remaining lines
                if(stationQt <= 1):
                    break

            else:
                sys.exit("Formating error encountered while parsing the API answer: " + currentICAO + "should be a queried ICAO id.")
        # safety added because with 1.3.4, I'm removing lines from metarWebPageText so i is going to exceed the number of lines
        if(i == len(metarWebPageText)-1):
            break
    del metarParserState
    del stationQt
    """


    # sorting

    # block commented with v1.3.5
    # I'm already doing that in the block uncommented with this version
    """
    returnedICAO = []
    for i in range(reportBodyStart,len(metarWebPageText)):
        # establishing the list of ICAO returned by the API and their order
        if(metarWebPageText[i] != ''):
            if(metarWebPageText[i].split()[0] == "METAR/SPECI"):
                returnedICAO.insert(len(returnedICAO),metarWebPageText[i].split()[1])
    """

    if(returnedICAO != stationICAOlist):

        if(len(returnedICAO) < len(stationICAOlist)):
            metarWebPageText.insert(5," /!\\ WARNING: No weather information was found for one or more of the requested ICAO /!\\")
            metarWebPageText.insert(6,'')
            reportBodyStart = reportBodyStart + 2
            # remove from stationICAOlist the ICAO absents from the API answer, otherwise it messes the sorting as stationICAOlist is used to determine the order
            icaoToRemove = []
            for icaoInQuery in range(0,len(stationICAOlist)):
                if(stationICAOlist[icaoInQuery] not in returnedICAO):
                    icaoToRemove.insert(0,icaoInQuery)
            while(len(icaoToRemove)):
                del stationICAOlist[icaoToRemove[0]]
                del icaoToRemove[0]
            del icaoToRemove
        elif(len(returnedICAO) > len(stationICAOlist)):
            sys.exit("The API returned information for more ICAO stations than requested.")

        # checking if there is a need to sort
        if(len(returnedICAO) > 1 and len(stationICAOlist) > 1):
            currentUnsortedOrder = []
            for c in range(0,len(stationICAOlist)):
                for d in range(0,len(returnedICAO)):
                    if(stationICAOlist[c] == returnedICAO[d]):
                        currentUnsortedOrder.insert(len(currentUnsortedOrder),d)
                        break
            # if currentUnsortedOrder isn't sorted in ascendent numbers, then the metar/taf blocks need to be sorted
            if(all(currentUnsortedOrder[c] <= currentUnsortedOrder[c+1] for c in range(len(currentUnsortedOrder) - 1)) == False):

                numberOfStationsSorted = 1
                # the sorting is looped until a full loop either sort as many metar/taf as their is ICAO pair matchings between the query and the answer or until a full loop complete without having to change the order of anything
                # it's because, curently, if say the blocks are in the order 2,3,1 the first for will do:
                # moving the 2 -> 3,2,1 ; the 2 is in place, do nothing ; moving the 1 -> 1,3,2
                # now with this while it will keep sorting until everything is in its place
                # it's incredibly ugly and ineficient but it works, i'm tired, and this script shouldn't have to deal with big ICAO lists, so meh!
                while(numberOfStationsSorted):
                    numberOfStationsSorted = 0
                    for i in range(reportBodyStart,len(metarWebPageText)):
                        numberOfStationsAbove = 0
                        if(metarWebPageText[i] != ''):
                            if(metarWebPageText[i].split()[0] == "METAR/SPECI"):
                                currentICAO = metarWebPageText[i].split()[1]

                                if(i > reportBodyStart):
                                    for n in range(reportBodyStart,i-1):
                                        if(metarWebPageText[n] != ''):
                                            if(metarWebPageText[n].split()[0] == "METAR/SPECI"):
                                                numberOfStationsAbove = numberOfStationsAbove + 1
                                else:
                                    numberOfStationsAbove = 0

                                # if the station isn't at the right place
                                if(stationICAOlist[numberOfStationsAbove] != currentICAO):
                                    # find where the station was supposed to go
                                    ICAOstationPosition = -1
                                    for n in range(0,len(stationICAOlist)):
                                        if(stationICAOlist[n] == currentICAO):
                                            ICAOstationPosition = n
                                            break
                                    # if the api returned a station that wasn't in the query, somehow, just disregard it
                                    if(ICAOstationPosition == -1):
                                        continue
                                    lineToMoveTheStationTo = 0
                                    emptyLinesCounted = 0
                                    linesToMove = 0
                                    if(ICAOstationPosition == 0):
                                        lineToMoveTheStationTo = reportBodyStart
                                    else:
                                        for textLineCount in range(reportBodyStart,len(metarWebPageText)):
                                            if(metarWebPageText[textLineCount] == ''):
                                                emptyLinesCounted = emptyLinesCounted + 1
                                            if(emptyLinesCounted == (ICAOstationPosition+1)*2):
                                                lineToMoveTheStationTo = textLineCount + 1
                                                break
                                    emptyLinesCounted = 0
                                    # counting the number of lines in the metar/taf block
                                    for n in range(i,len(metarWebPageText)):
                                        if(metarWebPageText[n] == ''):
                                            emptyLinesCounted = emptyLinesCounted + 1
                                        if(emptyLinesCounted == 2):
                                            break
                                        linesToMove = linesToMove + 1
                                    del emptyLinesCounted
                                    # if the station is supposed to be higher than it is, move it up
                                    if(ICAOstationPosition < numberOfStationsAbove):
                                        # moving first the empty line above the metar/speci first line, that way it will end up below the metar/taf block
                                        metarWebPageText.insert(lineToMoveTheStationTo,metarWebPageText[i-1])
                                        del metarWebPageText[i]
                                        for n in range(0,linesToMove):
                                            metarWebPageText.insert(lineToMoveTheStationTo,metarWebPageText[i+linesToMove-1])
                                            del metarWebPageText[i+linesToMove]
                                    # if the station is supposed to be lower than it is, move it down
                                    else:
                                        # there's an empty line under every TAF even the last one, it means lineToMoveTheStationTo point to just under an empty line under a taf
                                        # if I don't change it, it will create a double blank line above and no blank line under the block
                                        lineToMoveTheStationTo = lineToMoveTheStationTo - 1
                                        # moving first the empty line bellow the notam/taf block, it will end up above the block
                                        metarWebPageText.insert(lineToMoveTheStationTo,metarWebPageText[i+linesToMove])
                                        del metarWebPageText[i+linesToMove]
                                        # now lowering the metar/taf block
                                        for n in range(0,linesToMove):
                                            metarWebPageText.insert(lineToMoveTheStationTo-n,metarWebPageText[i+linesToMove-1-n])
                                            del metarWebPageText[i+linesToMove-1-n]
                                    numberOfStationsSorted = numberOfStationsSorted + 1
                                    del lineToMoveTheStationTo
                                    del linesToMove
                                    del ICAOstationPosition
                        # if all the stations that can be matched together have already been sorted, no need to continue
                        if(numberOfStationsSorted >= len(currentUnsortedOrder)):
                            numberOfStationsSorted = 0 # to leave the while loop
                            break # to leave the for loop

                del numberOfStationsSorted
                del numberOfStationsAbove
            del currentUnsortedOrder
    del currentICAO
    del reportBodyStart
    del returnedICAO
    
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