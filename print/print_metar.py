#!/usr/bin/python3

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

from Adafruit_Thermal import *
import sys

printer = Adafruit_Thermal("/dev/serial0", 19200, timeout=5)

# Print the 272x196 pixel logo in logo-nav-canada-blue.py
import bitmaps.logoAWC as LogoAWC
printer.printBitmap(LogoAWC.width, LogoAWC.height, LogoAWC.data)

printer.println(sys.stdin.read()) # I print the stdin, which comes from the cat filetoprint.txt
printer.feed(2) # make the printer feed a bit more paper, else the last 1.5 printed lines are bellow the printer cover
printer.setDefault() # Restore printer to defaults

sys.exit(0)