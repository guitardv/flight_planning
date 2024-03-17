<pre style="color:#54b9da">
    ______ __ _         __     __     ____   __                                
   / ____// /(_)____ _ / /_   / /_   / __ \ / /____ _ ____   ____   ___   _____
  / /_   / // // __ `// __ \ / __/  / /_/ // // __ `// __ \ / __ \ / _ \ / ___/
 / __/  / // // /_/ // / / // /_   / ____// // /_/ // / / // / / //  __// /    
/_/    /_//_/ \__, //_/ /_/ \__/  /_/    /_/ \__,_//_/ /_//_/ /_/ \___//_/     
             /____/                                                            
</pre>

# <!-- flight_planner -->
A collection of scripts to retrieve and collate informations relevant to flight planning.<br />

The end goal is to develop a modular flight planning environnment.<br />
This project is still in its early developpement stages, expect it to be riddled with issues and vulnerabilities.<br />
Since I'm working on it alone and on my spare time, don't expect any kind of consistent schedule. Part of my motivation for this project is to practice programming, so expect weird stuff like a (needlessly) large number of languages.<br /><br />
The intended use of this Work is educational, **DO NOT USE TO PREPARE AN ACTUAL FLIGHT**.<br />
While I'm aiming at making it a reliable source of aeronotical informations by taking steps such as only using official primary sources, this is still very much the work of an amateur and should be treated as such.<br /><br />
Please, read this file and the *LICENSE* file provided in the same folder before using this Work.

## Installation and Setup

This software is optimised for use with AMD64 (x86-64) *KDE* **Ubuntu 22.10** and the ARMv7 *Lite* version of **Raspbian GNU/Linux 11** runing an headless user in a restricted shell on startup and an administrator account accessed remotelly via SSH.<br />
If you're using linux, you can check your system version and CPU architecture with the commands:

```bash
    # System version:
    cat /etc/os-release | grep "PRETTY_NAME"

    # CPU architecture:
    lscpu | grep "Architecture"
``` 
<br />

### To install the software:

1. Download the latest version of the flight_planning repository
    - Either go to <https://github.com/guitardv/flight_planning>, download the code as an archive, and unzip it in its desired working directory;
    - Or clone the repository using Git:
        1. Make sure Git is installed and up to date with the command `git -v`. If git is installed, its version should be printed on the terminal. If git is reported as an unknown command, you can install it with `apt install git` or its equivalent command for your linux distribution. For more details about git, or to check its latest version number, see <https://git-scm.com/>.
        2. Clone the flight_planning repository:
            ```bash
            git clone git@github.com:guitardv/flight_planning.git
            ```
2. Install Python3 dependencies
    1. Python3 is required for this project. Make sure python is installed and up to date with the command `python --version`. You can install the latest version of python with the command `apt install python` or its equivalent for your linux distribution. For more details about python, or to check its latest version number, see: <https://www.python.org/>.
    2. To use pip to install the required python dependencies, start by making sure that pip is installed and up to date with the command `pip --version`. You can install the latest version of pip with the command `apt install python3-pip` or its equivalent for your linux distribution. If pip is already installed, you can update it to its latest version with the command `python3 -m pip install --upgrade pip`. For more details about pip, or to check its latest version number, see: <https://pip.pypa.io/en/stable/>.
    3. Install the python3 required dependencies listed in the *requirements.txt* file in the repository root directory (named "*flight_planning*" by default).
        ```bash
        pip install -r requirements.txt
        ```

### Setup:

The first time you run `flight-planner.sh`, the configuration utility will start and walk you through the configuration of all the modules. If you wish to access the configuration utility later, use the option `--config`.
```bash
./flight-planner.sh --config
```

At the moment, only the **NOTAM** and the **Print** modules requires some setting up. See their respective section in the "Overview of the modules" chapter bellow for informations on how to configure them manually.

## Overview of the modules
You'll find bellow an overview of the modules currently integrated/in developpment.

### METAR
Weather data provided by US Gov NOAA Aviation Weather Center API (<https://aviationweather.gov/data/api/#/Data/dataMetars>).<br />
By default, METAR/SPECI messages for the last 3 hours are repported. That number can be changed by editing the value of the variable `ageOfEarliestMetarMessageToBeReported` in metar/metar.py. TAF is provided by default, if you don't want the TAF to be appended after the METAR/SPECI messages, change the value of `includeTAF` to `false` in metar/metar.py.<br />

### NOTAM
NOTAMs provided by the FAA NOTAM API.<br />
Use of the FAA NOTAM API is subject to registration and manual approval by the FAA, for more information see : <https://api.faa.gov>.<br />

#### Manual setup
Once you have obtained a valid API client ID and key for the FAA NOTAM API, create the subfolder "SECRET" in the module folder "notam". Then, in the "SECRET" subfolder, create the files *api_client_id*, containing your API client ID, and *api_client_secret*, containing your API key. **These files must not contain any superfluous character, including any spaces or empty lines.**<br />

Exemple:

```bash
# Replace <API client ID> and <API key> with their respective value
mkdir notam/SECRET
echo "<API client ID>" > notam/SECRET/api_client_id
echo "<API key>" > notam/SECRET/api_client_secret
```

#### Usage

Using the argument `-h` or `--help` will show the usage.

```bash
./notam/notamRetriever.sh -h
```

<blockquote><pre><span style="white-space: pre;"><samp>

Retreive NOTAMs for specified locations from the NOTAM FAA API and format them for human readability.

Usage:
 notamRetriever.sh [options]
 notamRetriever.sh [options] -o|--output &lt;file&gt;

Options:
-t, --test            use local raw NOTAM data if available
-a, --airport &lt;ICAO&gt;  retreive NOTAMs associated to specified ICAO
                      locations, if multiple locations are provided
                      use quotation marks and separate locations
                      with a space, eg.: "CYHU CYUL"
                      default value: "CYHU CSY3"
-o, --output &lt;file&gt;   generated human readable NOTAMS will be saved
                      in the specified file,
                      default value: notam.txt
-h, --help            display this help message and exit

API Key:
Usage of the NOTAM FAA API requires the use of a client id and of a
client key. The client id and client key should be stored in the
subfolder "SECRET" under the name "api_client_id" and
"api_client_secret", respectively and without any extra character.
To obtain an API key or for more information about the FAA NOTAM API,
see: https://api.faa.gov .

Test:
If the option -t or --test is used, raw NOTAM data will be imported
from files in the "example" subfolder, if available, instead of being
downloaded. Example files names should start with the ICAO location
code (uppercase) and end with an extension corresponding to their
format (.geoJSON or .aixm).
Eg.: ./example/CYHU.geoJSON or ./example/KRSW_20230406.aixm
/!\ The only format supported for now is geoJSON.

</samp></span></pre></blockquote>

### Print

Printer : Adafruit product #597 "Mini Thermal Receipt Printer" (Zijiang ZJ-58 thermal printer).<br />
The printer is connected to a Raspberry Pi remotely accessed via SSH. Both the client machine and the RPi have a clone of this repo.<br />
Adafruit_Thermal python library provided by Adafruit and used under MIT license, for more information on the library see: <https://github.com/adafruit/Python-Thermal-Printer>.<br />
For more information on the printer, see: <https://www.adafruit.com/product/597>.

#### Manual setup
To be able to print the retrieved information without running the software on a SSH, you'll need create the subfolder "SECRET" in the "print" module folder, then create in that subfolder the files *printer_ip*, *user_id*, and *repo_path*, containing respectively the RPi IP, the name of the account on the RPi that will be used to print the retrieved information, and the path to the root folder of the flight_planning repo on the RPi. The module use SSH to send the printing command to the RPi, so you should provide an IP address and account name that can be reached via SSH from the shell you use to run the software. **These files must not contain any superfluous character, including any spaces or empty lines.**<br />

Exemple:

```bash
# Replace <IP>, <Account Name>, and <Path to the repo> with their respective value
mkdir print/SECRET
echo "<IP>" > print/SECRET/printer_ip
echo "<Account Name>" > print/SECRET/user_id
echo "<Path to the repo>" > print/SECRET/repo_path
```

## Additional Terms and Conditions
Please, read this file and the *LICENSE* file provided in the same folder.<br /><br />
The following terms and conditions ("Amendment") are meant as a complement to the Apache-2.0 license available in the *LICENSE* file provided in the same folder ("License") and use its definitions. Definitions introduced in the Amendment applies only to the Amendment. Terms presented in the Amendment and in the License ("Terms") are meant to be applied jointly. Any redundancy between or among any of the Terms presented in the Amendment and in the License is to be understood as emphasis and doesn't imply that one term is to be substituted to the other.<br />

By using the Work, You agree without restriction to the terms presented in this Amendment and in the License.  If You do not agree to these Terms, then You must not use the Work or any of its components.<br />
 - Disclaimer of Warranty (complement). The Work is provided on an "as is" basis without any warranty, express or implied, to the extent permitted by applicable law. It is Your responsibility to cross-check all information that may be supplied by the Work for pertinence, completeness, and accuracy.<br />
 - Availability. The Licensor reserves the right to discontinue or otherwise limit the availability, maintenance, or support of the Work or any component of the Work, whether offered as a standalone product or solely as a component, at any time.<br />
 - Limitation of Liability (complement). By using the Work, You acknowledge that **Your use of the Work is at Your sole risk**. You also acknowledge that the Work and any information it may provide is intended to be used for educational purposes only and **not as an actual flight planning tool**.<br />
 - Third-party works. The Work use third-party works, including softwares and websites. By using the Work You agree to their respective terms of use and acknowledge that the Licensor holds no control over these third-party works and over the information they may provide. For Your convenience, the Work may provide links or pointers to third-party articles and/or websites ("Third Party Websites"). They are provided for general information purposes only and do not constitute any offer or solicitation to buy or sell any services or products of any kind. Such Third Party Websites are not under the Licensor's control. The Licensor isn't responsible for the content of any Third Party Website or any link contained in a Third Party Website. The Licensor do not review, approve, monitor, endorse, warrant, or make any representations with respect to Third Party Websites, and the inclusion of any link in the Work, debit rewards offers or any other services provided in connection with them is not and does not imply an affiliation, sponsorship, endorsement, approval, investigation, verification or monitoring by the Licensor of any information contained in any Third Party Website. In no event will the Licensor or any Contributor be responsible for the information contained in such Third Party Website or for Your use of or inability to use such website. Access to any Third Party Website is at Your own risk, and You acknowledge and understand that linked Third Party Websites may contain terms and privacy policies that are different from the Licensor's. The Licensor is not responsible for such provisions, and expressly disclaim any liability for them. You are encouraged to read and evaluate the privacy and security policies on the specific Third Party Website You are entering. Views expressed in such Third Party Website are the current opinion of their author, and not necessarily those of the Licensor or any Contributor.<br />
 - Changes to these Terms and Conditions. The Licensor reserve the right, at their sole discretion, to modify or replace these Terms at any time. If a revision is material the Licensor will make reasonable efforts to provide at least 30 days' notice prior to any new Terms taking effect. Such a notice or the place to find such a notice will be included in the Work's README file. What constitutes a material change will be determined at the Licensor's sole discretion. By continuing to use the Work after those revisions become effective, You agree to be bound by the revised Terms. If You do not agree to the new Terms, in whole or in part, please stop using the Work.<br />
 - Conflict of Terms. In case of ambiguity, conflict, or otherwise inconsistency between or among any of the Terms presented in the Amendment and in the License, the Terms and provisions of this Amendment shall govern and control. Any questions regarding any perceived conflict of Terms shall be promptly brought to the attention of the Licensor via the "Issues" ticket submission tool of the Work's github repository (available at this address: <https://github.com/guitardv/flight_planning/issues>).<br />
 - Severability. If any provision of these Terms is held to be unenforceable or invalid, such provision will be changed and interpreted to accomplish the objectives of such provision to the greatest extent possible under applicable law and the remaining provisions will continue in full force and effect.<br />
