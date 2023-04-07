# flight_planning
A collection of scripts to retrieve and collate informations relevant to flight planning.

## Disclaimer :
The intended use of this software is educational, **DO NOT USE TO PREPARE AN ACTUAL FLIGHT**.<br>
Please, read this file and the *LICENSE* file provided in the same folder.<br><br>
/!\ **Warning**: Do not use as your sole or primary source of information to prepare an actual flight, please **follow relevant laws and regulations**.<br>
 - The software is provided on an "as is" basis without any warranty, express or implied, to the extent permitted by applicable law. It is your responsibility to cross-check all information that may be supplied by the software for pertinence, completeness, and accuracy.<br>
 - The author reserves the right to discontinue or otherwise limit the availability, maintenance, or support related to this software or any component of this software, whether offered as a standalone product or solely as a component, at any time.<br>
 - By using this software, you acknowledge that **your use of this software is at your sole risk**.<br>
 - By using this software, you acknowledge that this software and the information it may provide is intended to be used for educational purposes only and **not as an actual flight planning tool**.<br>
 - This software use third-party works, including softwares and websites. By using this software you agree to their respective Terms of Use and acknowledge that the author holds no right or control over these third-party works and on the information they may provide.<br>
 - In case of ambiguity, conflict, or otherwise inconsistency between or among any of the terms presented in this file and in the *LICENSE* file, the most restrictive terms apply. Any questions regarding any perceived conflict of terms shall be promptly brought to the attention of the author via the "Issues" ticket submission tool of this software's github repository (available at this address: https://github.com/guitardv/flight_planning/issues).<br>
 - By using this software, you agree without restriction to the terms presented in this file and in the *LICENSE* file.  If you do not agree to these terms, then you must not use the software or any of its components.

## METAR :
Works only for Canadian airports.<br>
Weather data provided by Environment Canada and NAV CANADA via https.//flightplanning.navcanada.ca .

## NOTAM :
NOTAMs provided by the FAA NOTAM API.<br>
Use of the FAA NOTAM API is subject to registration and manual approval by the FAA, for more information see : https://api.faa.gov .

## Print :
Printer : Adafruit product #597 "Mini Thermal Receipt Printer" (Zijiang ZJ-58 thermal printer).<br>
The printer is connected to a Raspberry Pi accessed via SSH. Both the client machine and the RPi have a clone of this repo.<br>
Adafruit_Thermal python library provided by Adafruit and used under MIT license, for more information on the library see: https://github.com/adafruit/Python-Thermal-Printer .<br>
For more information on the printer, see: https://www.adafruit.com/product/597 .
