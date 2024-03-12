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

# version 1.2
# import metar from designated airports (default: CYHU) and print them in the standard output

# AWWS (flightplanning.navcanada.ca) was decommissioned by NAV CANADA on 2024-02-28 in favor of CFPS (plan.navcanada.ca/wxrecall/), so the version 1.1 and earlier this script don't work anymore

import sys
import os
import time
from bs4 import BeautifulSoup
from urllib.request import Request, urlopen
from os.path import exists
from datetime import datetime, timezone

# total number of metar messages to report (current + previous), SPECI aren't included, all speci from the moment of the request to the last included METAR will be reported
numberOfMetarMessagesToBeReported = 3

baseURL = "https://metar-taf.com/"
metarBaseURLtext = "history/"
tafBaseURLtext = "taf/"
DefaultAirport = "CYHU"
metarURL = []
metarCheckAirportURL = []
tafURL = []
hdr = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:123.0) Gecko/20100101 Firefox/123.0',
       'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'}
argvLen = len(sys.argv)

# for the program to stay open in the terminal and refresh
# the METAR every minute instead of printing the METAR once and closing,
# use the argument -l or --looped, udvLooped will be set to 1
udvLooped = 2

if(argvLen == 1):
    metarURL.append(baseURL+metarBaseURLtext+DefaultAirport)
    metarCheckAirportURL.append(baseURL+DefaultAirport)
    tafURL.append(baseURL+tafBaseURLtext+DefaultAirport)
elif(argvLen > 1):
    if("-l" in sys.argv or "--looped" in sys.argv):
        udvLooped = 1
        if(argvLen == 2):
            metarURL.append(baseURL+metarBaseURLtext+DefaultAirport)
            metarCheckAirportURL.append(baseURL+DefaultAirport)
            tafURL.append(baseURL+tafBaseURLtext+DefaultAirport)
    if(sys.argv[1] != "-l" and sys.argv[1] != "--looped"):
        metarURL.append(baseURL + metarBaseURLtext + sys.argv[1])
        metarCheckAirportURL.append(baseURL + sys.argv[1])
        tafURL.append(baseURL + tafBaseURLtext + sys.argv[1])
    if(argvLen>2):
        for i in range(2, argvLen):
            if(sys.argv[i] != "-l" and sys.argv[i] != "--looped"):
                metarURL.append(baseURL + metarBaseURLtext + sys.argv[i])
                metarCheckAirportURL.append(baseURL + sys.argv[i])
                tafURL.append(baseURL + tafBaseURLtext + sys.argv[i])
else:
    sys.exit("Invalid argument length.")

del argvLen

metarRequest = []
for i in range(len(metarURL)):
    metarRequest.append(Request(metarURL[i], headers=hdr))
tafRequest = []
for i in range(len(tafURL)):
    tafRequest.append(Request(tafURL[i], headers=hdr))
metarCheckAirportRequest = []
for i in range(len(metarCheckAirportURL)):
    metarCheckAirportRequest.append(Request(metarCheckAirportURL[i], headers=hdr))



def isMetarFromSpecifiedAirport(metarCheckAirportRequestToUse):

    homeWebPage = BeautifulSoup(urlopen(metarCheckAirportRequestToUse).read().decode("UTF-8"), "lxml")
    homeWebPageText = homeWebPage.get_text().splitlines()
    
    for i in range(len(homeWebPageText)):
        if(homeWebPageText[i].strip()[:25] == "The METAR station used is"):
            metarTafText.append("/!\\ " + homeWebPageText[i].strip())
            metarTafText.append("")
            break

# Fin isMetarFromSpecifiedAirport
#################


def metarReportBuilder(metarRequestToUse):

    metarWebPage = BeautifulSoup(urlopen(metarRequestToUse).read().decode("UTF-8"), "lxml")

    metarWebPageText = metarWebPage.get_text().splitlines()

    listOfLinesToRemove = []


    for i in range(len(metarWebPageText)):
        if(metarWebPageText[i] == '' or metarWebPageText[i] == ' '):
            listOfLinesToRemove.append(i)
    if(len(listOfLinesToRemove)>0):
        for i in range(len(listOfLinesToRemove)-1,-1,-1):
            del metarWebPageText[listOfLinesToRemove[i]]
    del listOfLinesToRemove


    metarStartLine = 0
    for i in range(len(metarWebPageText)):
        if(metarWebPageText[i][:13] == "METAR history"):
            # Append the line containing the code and name of the airport the metar is refering to
            metarTafText.append(metarWebPageText[i][14:])
            metarTafText.append("")
        elif(metarWebPageText[i] == "METAR/SPECI"):
            metarStartLine = i
            break
    if(metarStartLine == 0):
        print("\nERROR: metar.py: Unable to locate METAR in the source web page.\n")
        sys.exit(1)
    else:
        i = 0
        while i < numberOfMetarMessagesToBeReported:
            if(len(metarWebPageText)<metarStartLine+9):
                print("\nERROR: metar.py: end of web metar report reach before parsing the specified number of METAR message to include in the report.\n")
                break
            if(metarWebPageText[metarStartLine+9] == "METAR/SPECI"):
                # if the last parsed metar was the first of the day, the table headers are repeated just after it and move the frame by 9 lines
                metarStartLine=metarStartLine+9
            if(metarWebPageText[metarStartLine+7][-1:] != '-'):
                # if the wind isn't reported as a range but a single value, the next metar/speci message is 8 lines down insted of 9
                numberOfLinesToNextMessage = 8
            else:
                numberOfLinesToNextMessage = 9
            if(metarWebPageText[metarStartLine+numberOfLinesToNextMessage].lstrip()[:5] == "METAR"):
                # if the message is a metar (not a speci), increment the number of metar included in the report (i)
                i = i+1
            metarTafText.append(metarWebPageText[metarStartLine+numberOfLinesToNextMessage].strip())
            # after including the METAR/SPECI message in the report, the framed is moved by 9 lines to end up on the next message or METAR/SPECI header if the day changed
            metarStartLine=metarStartLine+numberOfLinesToNextMessage
        del numberOfLinesToNextMessage
        del i
    del metarStartLine

    # uncomment to write the unformated text of the metar web page to a file (used for test and debug)
    #MetarFilePath = "lastImportedMetar.txt"
    #with open(MetarFilePath, "w") as metarFile:
    #    metarFile.write('\n'.join(metarWebPageText))

# Fin metarReportBuilder
#################

def tafReportBuilder(tafRequestToUse):
    tafWebPage = BeautifulSoup(urlopen(tafRequestToUse).read().decode("UTF-8"), "lxml")
    tafWebPageText = tafWebPage.get_text().splitlines()

    listOfLinesToRemove = []
    for i in range(len(tafWebPageText)):
        if(tafWebPageText[i] == '' or tafWebPageText[i] == ' '):
            listOfLinesToRemove.append(i)
    if(len(listOfLinesToRemove)>0):
        for i in range(len(listOfLinesToRemove)-1,-1,-1):
            del tafWebPageText[listOfLinesToRemove[i]]
    del listOfLinesToRemove

    tafStartLine = 0
    for i in range(len(tafWebPageText)):
        if(tafWebPageText[i] == "Original"):
            tafStartLine = i
            break
    if(tafStartLine == 0):
        print("\nERROR: metar.py: Unable to locate TAF in the source web page.\n")
        sys.exit(1)
    
    if(tafWebPageText[i+1][:3] == "TAF"):
        metarTafText.append(tafWebPageText[i+1])
    else:
        print("\nERROR: metar.py: Unable to locate TAF report in the source web page.\n")
        sys.exit(1)


    # uncomment to write the unformated text of the taf web page to a file (used for test and debug)
    #TafFilePath = "lastImportedTaf.txt"
    #with open(TafFilePath, "w") as tafFile:
    #    tafFile.write('\n'.join(tafWebPageText))

# Fin tafReportBuilder
#################

while(udvLooped):
    if(udvLooped == 2):
        udvLooped = 0

    # if the script is running on the RPi
    if(exists("/sys/class/backlight/10-0045/bl_power")):
        with open("/sys/class/backlight/10-0045/bl_power", 'r') as backlight_power:
            # If the display is turned off, don't go further and check the display power status every minute
            while(backlight_power.read() == '1'):
                time.sleep(60)

    timeOfLoopStart = datetime.now(timezone.utc)

    metarTafText = []
    metarTafText.append("METAR/TAF")
    metarTafText.append("")
    #metarTafText.append("Request generated at " + timeOfLoopStart.year + "-" + timeOfLoopStart.month + "-" + timeOfLoopStart.day + " " + timeOfLoopStart.hour + ":" + timeOfLoopStart.minute + " UTC")
    #metarTafText.append("Request generated at " + timeOfLoopStart.strftime("%Y-%m-%d %H:%M %Z."))
    metarTafText.append(timeOfLoopStart.strftime("Request generated at %Y-%m-%d %H:%M %Z."))
    metarTafText.append("")


    for i in range(len(metarRequest)):
        metarTafText.append("")
        if(i>0):
            metarTafText.append("####")
            metarTafText.append("")
        isMetarFromSpecifiedAirport(metarCheckAirportRequest[i])
        metarReportBuilder(metarRequest[i])
        metarTafText.append("")
        tafReportBuilder(tafRequest[i])
    
    metarTafText.append("")
    metarTafText.append("----")
    metarTafText.append("Weather data provided by metar-taf.com")


    if(udvLooped):
        os.system("clear")
        print('\n'.join(metarTafText))
        time.sleep(60)
    else:
        print('\n','\n'.join(metarTafText),'\n')

sys.exit(0)

#si je veux ecrire le metar (for test and debug)
MetarTafReportFilePath = "lastMetarTafReport.txt"
with open(MetarTafReportFilePath, "w") as metarTafFile:
    metarTafFile.write('\n'.join(metarTafText))
