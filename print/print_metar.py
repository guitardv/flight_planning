#!/usr/bin/python3

from Adafruit_Thermal import *
import sys

printer = Adafruit_Thermal("/dev/serial0", 19200, timeout=5)

# Print the 272x196 pixel logo in logo-nav-canada-blue.py
import bitmaps.logoNavCanada as NavCanadaLogo
printer.printBitmap(NavCanadaLogo.width, NavCanadaLogo.height, NavCanadaLogo.data)

printer.println(sys.stdin.read()) # I print the stdin, which comes from the cat filetoprint.txt
printer.feed(2) # make the printer feed a bit more paper, else the last 1.5 printed lines are bellow the printer cover
printer.setDefault() # Restore printer to defaults

sys.exit(0)