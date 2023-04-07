# flight_planning
A collection of scripts to retrieve and collate informations relevant to flight planning.<br>

The end goal is to develop a modular flight planning environnment.<br>
This project is still in its early developpement stages, expect it to be riddled with issues and vulnerabilities.<br>
Since I'm working on it alone and on my spare time, don't expect any kind of consistent schedule. Part of my motivation for this project is to practice programming, so expect weird stuff like a (needlessly) large number of languages.<br><br>
The intended use of this Work is educational, **DO NOT USE TO PREPARE AN ACTUAL FLIGHT**.<br>
While I'm aiming at making it a reliable source of aeronotical informations by taking steps such as only using official primary sources, the Work is still very much the work of an amateur and should be treated as such.<br>
Please, read this file and the *LICENSE* file provided in the same folder before using the Work.<br>

## Overview of the modules
You'll find bellow an overview of the modules currently integrated/in developpment.

### METAR :
Works only for Canadian airports.<br>
Weather data provided by Environment Canada and NAV CANADA via https.//flightplanning.navcanada.ca .

### NOTAM :
NOTAMs provided by the FAA NOTAM API.<br>
Use of the FAA NOTAM API is subject to registration and manual approval by the FAA, for more information see : https://api.faa.gov .

### Print :
Printer : Adafruit product #597 "Mini Thermal Receipt Printer" (Zijiang ZJ-58 thermal printer).<br>
The printer is connected to a Raspberry Pi remotely accessed via SSH. Both the client machine and the RPi have a clone of this repo.<br>
Adafruit_Thermal python library provided by Adafruit and used under MIT license, for more information on the library see: https://github.com/adafruit/Python-Thermal-Printer .<br>
For more information on the printer, see: https://www.adafruit.com/product/597 .

## Disclaimer :
The intended use of this Work is educational, **DO NOT USE TO PREPARE AN ACTUAL FLIGHT**.<br>
Please, read this file and the *LICENSE* file provided in the same folder.<br><br>
/!\ **Warning**: Do not use as Your sole or primary source of information to prepare an actual flight, please **follow relevant laws and regulations**.<br>
 - The Work is provided on an "as is" basis without any warranty, express or implied, to the extent permitted by applicable law. It is Your responsibility to cross-check all information that may be supplied by the Work for pertinence, completeness, and accuracy.<br>
 - The Licensor reserves the right to discontinue or otherwise limit the availability, maintenance, or support related to the Work or any component of the Work, whether offered as a standalone product or solely as a component, at any time. This term does not apply to Derivative Works.<br>
 - By using the Work, You acknowledge that **Your use of the Work is at Your sole risk**.<br>
 - By using the Work, You acknowledge that the Work and any information it may provide is intended to be used for educational purposes only and **not as an actual flight planning tool**.<br>
 - the Work use third-party works, including softwares and websites. By using the Work You agree to their respective Terms of Use and acknowledge that the Licensor holds no control over these third-party works and over the information they may provide.<br>
 - In case of ambiguity, conflict, or otherwise inconsistency between or among any of the terms presented in this file and in the *LICENSE* file, the most restrictive terms apply. Any questions regarding any perceived conflict of terms shall be promptly brought to the attention of the Licensor via the "Issues" ticket submission tool of the Work's github repository (available at this address: https://github.com/guitardv/flight_planning/issues).<br>
 - By using the Work, You agree without restriction to the terms presented in this file and in the *LICENSE* file.  If You do not agree to these terms, then You must not use the Work or any of its components.