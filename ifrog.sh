#!/bin/bash

# Welcome to ifrog cli. This cli has the power to ping the server, view the server system version
# Create User, Delete User, Get Storage Info, Create Repository, Update Repository
# List Repositorie.

# Upon first use you should be prompted to login to gain access to the cli.

set -euo pipefail

# Path to config file
# CONFIG_FILE="$HOME/.ifrog/config.json"
CONFIG_FILE="./config.json"

# Function to load config
load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: Config file not found at $CONFIG_FILE"
        exit 1
    fi
    REPO_URL=$(jq -r '.repository_url' "$CONFIG_FILE")
    ACCESS_TOKEN=$(jq -r '.access_token' "$CONFIG_FILE")
    USERNAME=$(jq -r '.username' "$CONFIG_FILE")
}

# Helper function to update config file
update_config() {
    jq --arg username "$1" '. + {username: $username}' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
}

# Helper function to call the API
call_api() {
    local method=$1
    local endpoint=$2
    local data=$3

    curl -s -H "Authorization: Bearer $ACCESS_TOKEN" -X "$method" \
        -H "Content-Type: application/json" \
        -d "$data" \
        "$REPO_URL$endpoint"
}

# Commands
system_ping() {
    response=$(call_api GET "/artifactory/api/system/ping" "")
    echo "$response"
}

system_version() {
    response=$(call_api GET "/artifactory/api/system/version" "")
    echo "$response"
}

login() {
    echo -n "Enter username: "
    read -r username
    echo -n "Enter password: "
    read -s -r password
    echo

    response=$(curl -s -u"$username:$password" -X GET "$REPO_URL/api/system/version")

    if echo "$response" | grep -q '"version"'; then
        echo "Login successful."
        update_config "$username"
    elif echo "$response" | grep -q '"message".*"Authentication is required"'; then
        echo "Login failed: Authentication is required."
        exit 1
    else
        echo "Login failed: Incorrect username/password."
        exit 1
    fi
}

create_user() {
    local username=$1
    local email=$2
    local password=$3

    data=$(jq -n --arg uname "$username" --arg uemail "$email" --arg upass "$password" \
        '{username: $uname, password: $upass, email: $uemail, admin: false, profile_updatable: true}')
    response=$(call_api POST "/access/api/v2/users" "$data")
    echo "$response"
}

delete_user() {
    local username=$1
    response=$(call_api DELETE "/access/api/v2/users/$username" "")
    echo "$response"
}

get_storage_info() {
    response=$(call_api GET "/artifactory/api/storageinfo" "")
    echo "$response"
}


create_repository() {
    # Currently only makes local repo.
    local repo_key=$1
    local package_type=$2

    data=$(jq -n --arg key "$repo_key" --arg type "$package_type" \
        '{key: $key, rclass: "local", packageType: $type}')
    response=$(call_api PUT "/artifactory/api/repositories/$repo_key" "$data")
    echo "$response"
}

list_repositories() {
    response=$(call_api GET "/artifactory/api/repositories" "")
    echo "$response"
}

# Pre-check for username in config
pre_check_login() {
    load_config
    if [ -z "$USERNAME" ]; then
        echo "No username found in config. Initiating login..."
        login
    fi
}

# Main CLI logic
pre_check_login

while getopts ":hv-:" opt; do
    case $opt in
        -) # Long options
            case "${OPTARG}" in
                ping)
                    system_ping
                    exit
                    ;;
                version)
                    system_version
                    exit
                    ;;
                login)
                    login
                    exit
                    ;;
                create-user)
                    create_user "$2" "$3" "$4"
                    exit
                    ;;
                delete-user)
                    delete_user "$2"
                    exit
                    ;;
                storage-info)
                    get_storage_info
                    exit
                    ;;
                create-repo)
                    create_repository "$2" "$3"
                    exit
                    ;;
                list-repos)
                    list_repositories
                    exit
                    ;;
                help)
                    echo "Usage: ifrog [--ping | --version | --login | --create-user <username> <email> <password> | --delete-user <username> | --storage-info | --create-repo <repo-key> <package-type> | --list-repos]"
                    exit
                    ;;
                *)
                    echo "Invalid option: --${OPTARG}" >&2
                    exit 1
                    ;;
            esac
            ;;
        h)
            echo "Usage: ifrog [--ping | --version | --login | --create-user <username> <email> <password> | --delete-user <username> | --storage-info | --create-repo <repo-key> <package-type> | --list-repos]"
            exit
            ;;
        v)
            echo "ifrog CLI version 1.0"
            exit
            ;;
        ?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

if [ $OPTIND -eq 1 ]; then
    echo "Usage: $0 [--ping | --version | --login | --create-user <username> <email> <password> | --delete-user <username> | --storage-info | --create-repo <repo-key> <package-type> | --list-repos]"
    exit 1
fi
