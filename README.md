# ifrog CLI Tool

The **ifrog CLI Tool** is my Bash-based cli designed for managing JFrog Artifactory instances via REST APIs. It supports common administrative tasks such as repository management, user creation, and system-level operations.

##  Designed for Mac, may not be compatible with windows.
---

## Table of Contents
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Commands](#commands)
- [Development Decisions](#development-decisions)
  - [Sources Referenced](#sources-referenced)
  - [Rationale for Design Decisions](#rationale-for-design-decisions)
- [Other](#other)

---

## Installation

1. **Clone the Repository**
   ```bash
   git clone git@github.com:IkobiLynch/ifrog-cli.git
   cd ifrog-cli

2. Make this script/file executable chmod +x ifrog_setup.sh

3. Run the provided `ifrog_setup.sh` script to install dependencies and set up the CLI tool. This script will:
- Install required tools like `jq` and `curl`.
- Set up the `ifrog` command in your system PATH.
- Install the man page for the CLI.

---
## Configuration
The CLI uses a JSON configuration file located at ~/.ifrog/config.json. This file stores details such as the repository URL, access token, and username. The configuration file is generated or updated during the first login. There is an example configuration file named config.example.json copy and rename the file to config.json locally. Enter the access token provided and then run a cli login command or any command. It will ask you to login and automatically populate the username variable on succesful login.

## Usage
Run ifrog --help to view available command and their usage. 

### Command	Descriptions   
* --ping	Test connectivity to the Artifactory instance.
    **example: *ifrog --ping***

* --version	Display the version of the Artifactory instance.
    **example: *ifrog --version***

* --login	Log in to the Artifactory instance using a username and password.
    **example: *ifrog --login***

* --create-user	Create a user: <username> <email> <password>.
    **example: *ifrog --create-user "testuser" "testuser@example.com" "password123"***

* --delete-user	Delete a user: <username>.
    **example: *ifrog --delete-user "username"***

* --storage-info	Display storage usage information.
    **example: *ifrog --storage-info***

* --create-repo	Create a repository: <repo-key> <package-type>.
    **example: *ifrog --create-repo***

* --list-repos	List all repositories in the Artifactory instance.
    **example: *ifrog --list-repos***

**Possible package types** for use in **--create-repo** command include: 
  - "alpine"|"cargo"|"composer"|"bower"|"chef"|"cocoapods"|"conan"|"conda"|"cran"|"debian"|"docker"|"helm"|"helmoci"|"huggingfaceml"|"gems"|"gitlfs"|"go"|"gradle"|"ivy"|"maven"|"npm"|"nuget"|"oci"|"opkg"|"pub"|"puppet"|"pypi"|"rpm"|"sbt"|"swift"|"terraform"|"terraformbackend"|"vagrant"|"yum"|"generic" (default)
  
## Development Decisions
In this section I provide details on the decisions made during creation of this CLI tool, references and sources used. 

Sources Referenced
1. [Official JFrog Artifactory REST API Documentation](https://jfrog.com/help/r/jfrog-rest-apis/artifactory-rest-apis)
    - Used for understanding JFROG REST API endpoints.

2. [Bash scripting cheatsheet](https://devhints.io/bash)
    - Used for quick reference when writing bash scripts. 

3. [Real Time Man Page Renderer](https://roperzh.github.io/grapse/)
    - Used to visualize man page in realtime to speed up creation.

4. [Bash Getopts](https://www.golinuxcloud.com/bash-getopts/)
    - Also used when writing bash script.

5. [OpenAI](https://chatgpt.com/)
    - Used to quickly receive feedback and find commands and usage for other tools like jq allowing me to save time finding commands, etc... 

Rationale for Design Decisions

1. Bash Language Choice
    - I chose bash because it is pre-installed on most Unix-like systems, making the cli accessible with less prerequisite steps. Also I am very familiar with scripting. Another possible option would have been python, due to it also being pre installed on most unix systems.

2. JSON Configuration File 
    - Chose this to store credentials and settings persistently as it is easily understandable and it is broadly used so there are plenty of tools already created to work with its format. 

3. REST API via curl
    - curl was chosen for the HTTP requests due too its availability and simplicity in bash.

4. Error Handling
    - I enabled set -euo pipefail to enforce strict error handling, preventing unexpected behavior. In this case I was not quite sure if it really mattered since each command/function is like a script to itself. But, it is good practice so I always do it when scripting. 

5. Man Page
    - I included the man page because I use man pages a lot and I figured if I create an api I should also have a man page that others can use.

## Other 
In this section I just give some additional info like limitations and places where I know the api is weak and should be improved for a production setting.

1. The login:
    - Currently to login it only checks if the username field in the config file is populated. So if any arbitrary name/word is inside the config.json file as a value for username. The cli will believe you have logged in. However due to lacking an access token the other commands won't/shouldn't work.

2. Other OS compatability
    - I cannot guarantee it working perfectly on an OS other than Mac because I did not test it, especially windows.

