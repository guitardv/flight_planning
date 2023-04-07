# flight_planning
A collection of scripts to retrieve and collate informations relevant to flight planning.

## Disclaimer :
**For educational purposes only.**<br>
Please, read this file and the *LICENSE* file.<br>
/!\ **Warning**: Do not use as your sole or primary source of information to prepare an actual flight, please **follow relevant laws and regulations**.<br>
/!\ **Warning**: The software is provided "as is" without any warranty, express or implied. It is your responsibility to cross-check all information that may be supplied by the software for pertinence, completeness, and accuracy.<br>
/!\ **Warning**: By using this software, you acknowledge that **your use of this software is at your sole risk**.<br>
/!\ **Warning**: By using this software, you agree without restriction to the terms presented in this file and in the *LICENSE* file, and acknowledge that the software is to be used for educational purposes only and not as an actual flight planning tool. The software use third-party softwares and websites, by using this software you agree to their respective Terms of Use and acknowledge that the author holds no right or control over these third-party softwares and websites, and on the information they may provide. If you do not agree to these terms, then you must not use the software or any of its components.

## METAR :
Works only for Canadian airports.<br>
Weather data provided by Environment Canada and NAV CANADA via https.//flightplanning.navcanada.ca .

## NOTAM :
NOTAMs provided by the FAA NOTAM API.<br>
Use of the FAA NOTAM API is subject to registration and manual approval by the FAA, for more information see : https://api.faa.gov .

## Print :
Printer : Adafruit product #597 "Mini Thermal Receipt Printer" (Zijiang ZJ-58 thermal printer).<br>
The printer is connected to a Raspberry Pi accessed via SSH. Both the client machine and the RPi have a clone of this repo.<br>
Adafruit_Thermal library provided by Adafruit, for more information on the library see: https://github.com/adafruit/Python-Thermal-Printer .<br>
For more information on the printer, see: https://www.adafruit.com/product/597 .
