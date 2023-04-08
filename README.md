# flight_planning
A collection of scripts to retrieve and collate informations relevant to flight planning.<br>

The end goal is to develop a modular flight planning environnment.<br>
This project is still in its early developpement stages, expect it to be riddled with issues and vulnerabilities.<br>
Since I'm working on it alone and on my spare time, don't expect any kind of consistent schedule. Part of my motivation for this project is to practice programming, so expect weird stuff like a (needlessly) large number of languages.<br><br>
The intended use of this Work is educational, **DO NOT USE TO PREPARE AN ACTUAL FLIGHT**.<br>
While I'm aiming at making it a reliable source of aeronotical informations by taking steps such as only using official primary sources, the Work is still very much the work of an amateur and should be treated as such.<br>
<br>/!\ **Warning**: Do not use as Your sole or primary source of information to prepare an actual flight, please **follow relevant laws and regulations**.<br><br>
Please, read this file and the *LICENSE* file provided in the same folder before using this Work.

## Overview of the modules
You'll find bellow an overview of the modules currently integrated/in developpment.

### METAR :
Works only for Canadian airports.<br>
Weather data provided by Environment Canada and NAV CANADA via <https://flightplanning.navcanada.ca>.

### NOTAM :
NOTAMs provided by the FAA NOTAM API.<br>
Use of the FAA NOTAM API is subject to registration and manual approval by the FAA, for more information see : <https://api.faa.gov>.

### Print :
Printer : Adafruit product #597 "Mini Thermal Receipt Printer" (Zijiang ZJ-58 thermal printer).<br>
The printer is connected to a Raspberry Pi remotely accessed via SSH. Both the client machine and the RPi have a clone of this repo.<br>
Adafruit_Thermal python library provided by Adafruit and used under MIT license, for more information on the library see: <https://github.com/adafruit/Python-Thermal-Printer>.<br>
For more information on the printer, see: <https://www.adafruit.com/product/597>.

## Additional Terms and Conditions
Please, read this file and the *LICENSE* file provided in the same folder.<br><br>
The following terms and conditions ("Amendment") are meant as a complement to the Apache-2.0 license available in the *LICENSE* file provided in the same folder ("License") and use its definitions. Definitions introduced in the Amendment applies only to the Amendment. Terms presented in the Amendment and in the License ("Terms") are meant to be applied jointly. Any redundancy between or among any of the Terms presented in the Amendment and in the License is to be understood as emphasis and doesn't imply that one term is to be substituted to the other.<br>

By using the Work, You agree without restriction to the terms presented in this Amendment and in the License.  If You do not agree to these Terms, then You must not use the Work or any of its components.<br>
 - Disclaimer of Warranty (complement). The Work is provided on an "as is" basis without any warranty, express or implied, to the extent permitted by applicable law. It is Your responsibility to cross-check all information that may be supplied by the Work for pertinence, completeness, and accuracy.<br>
 - Availability. The Licensor reserves the right to discontinue or otherwise limit the availability, maintenance, or support of the Work or any component of the Work, whether offered as a standalone product or solely as a component, at any time.<br>
 - Limitation of Liability (complement). By using the Work, You acknowledge that **Your use of the Work is at Your sole risk**. You also acknowledge that the Work and any information it may provide is intended to be used for educational purposes only and **not as an actual flight planning tool**.<br>
 - Third-party works. The Work use third-party works, including softwares and websites. By using the Work You agree to their respective terms of use and acknowledge that the Licensor holds no control over these third-party works and over the information they may provide. For Your convenience, the Work may provide links or pointers to third-party articles and/or websites ("Third Party Websites"). They are provided for general information purposes only and do not constitute any offer or solicitation to buy or sell any services or products of any kind. Such Third Party Websites are not under the Licensor's control. The Licensor isn't responsible for the content of any Third Party Website or any link contained in a Third Party Website. The Licensor do not review, approve, monitor, endorse, warrant, or make any representations with respect to Third Party Websites, and the inclusion of any link in the Work, debit rewards offers or any other services provided in connection with them is not and does not imply an affiliation, sponsorship, endorsement, approval, investigation, verification or monitoring by the Licensor of any information contained in any Third Party Website. In no event will the Licensor or any Contributor be responsible for the information contained in such Third Party Website or for Your use of or inability to use such website. Access to any Third Party Website is at Your own risk, and You acknowledge and understand that linked Third Party Websites may contain terms and privacy policies that are different from the Licensor's. The Licensor is not responsible for such provisions, and expressly disclaim any liability for them. You are encouraged to read and evaluate the privacy and security policies on the specific Third Party Website You are entering. Views expressed in such Third Party Website are the current opinion of their author, and not necessarily those of the Licensor or any Contributor.<br>
 - Changes to these Terms and Conditions. The Licensor reserve the right, at their sole discretion, to modify or replace these Terms at any time. If a revision is material the Licensor will make reasonable efforts to provide at least 30 days' notice prior to any new Terms taking effect. Such a notice or the place to find such a notice will be included in the Work's README file. What constitutes a material change will be determined at the Licensor's sole discretion. By continuing to use the Work after those revisions become effective, You agree to be bound by the revised Terms. If You do not agree to the new Terms, in whole or in part, please stop using the Work.<br>
 - Conflict of Terms. In case of ambiguity, conflict, or otherwise inconsistency between or among any of the Terms presented in the Amendment and in the License, the Terms and provisions of this Amendment shall govern and control. Any questions regarding any perceived conflict of Terms shall be promptly brought to the attention of the Licensor via the "Issues" ticket submission tool of the Work's github repository (available at this address: <https://github.com/guitardv/flight_planning/issues>).<br>
 - Severability. If any provision of these Terms is held to be unenforceable or invalid, such provision will be changed and interpreted to accomplish the objectives of such provision to the greatest extent possible under applicable law and the remaining provisions will continue in full force and effect.<br>
