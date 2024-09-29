#!/usr/bin/env bash

set -euo pipefail

if [[ "${NO_COLOR-}" = "" && ( -t 1 || "${FORCE_COLOR-}" != "" ) ]]; then
    C_RESET='\033[0m'
    C_RED='\033[0;31m'
    C_GREEN='\033[0;32m'
    C_YELLOW='\033[0;33m'
    C_DIM='\033[0;37m'
    C_BOLD='\033[1m'
    PROGRESS=-#
else
    C_RESET=
    C_RED=
    C_GREEN=
    C_YELLOW=
    C_DIM=
    C_BOLD=
    PROGRESS=-Ss
fi

announce() {
    echo -e "${C_RESET}${C_BOLD}$1${C_RESET}" "$2" >&2
}

fail() {
    echo -e "${C_RED}$1${C_RESET}" "$2" >&2
    exit 1
}

pass() {
    echo -e "${C_GREEN}$1${C_RESET}" "$2" >&2
}

ignore() {
    echo -e "${C_YELLOW}$1${C_RESET}" "$2" >&2
}

start_debug() {
    echo -e "${C_DIM}$1" >&2
}

end_debug() {
    echo -en "${C_RESET}" >&2
}

readonly INST_NAME=zigup
readonly LANG_NAME=Zig
readonly TOOL_NAME=zig
readonly VERSION=0.2.2

readonly INST_DIR="${INST_DIR-$HOME/.$INST_NAME}"
readonly NEW_PATH="\$HOME/.$INST_NAME:\$HOME/.$TOOL_NAME:\$PATH"

print_usage_instructions() {
    echo -e "Installs or updates ${C_BOLD}$INST_NAME $VERSION${C_RESET} - upgrader and version manager for $LANG_NAME.

${C_BOLD}Usage${C_RESET}: install [task]
${C_BOLD}Tasks${C_RESET}:
  help     print usage instructions for this tool
  version  print the version of this tool"
}

print_installer_version() {
    echo "$VERSION"
}

check_command_exists() {
    local CMD=$1
    local WHY=$2
    command -v "$CMD" >/dev/null ||
        fail missing "${C_BOLD}$CMD${C_RESET} for $WHY"
}

check_chmod_exists() {
    check_command_exists chmod 'changing file mode'
}

check_curl_exists() {
    check_command_exists curl 'downloading files'
}

check_mkdir_exists() {
    check_command_exists mkdir 'creating directories'
}

create_directory() {
    local DIR=$1
    if [ ! -d "$DIR" ]; then
        mkdir "$DIR" ||
            fail 'failed creating' "$DIR"
        pass created "$DIR"
    else
        ignore 'no need to create' "$DIR"
   fi
}

download_installer() {
    local SCRIPT
    SCRIPT="$INST_DIR/$INST_NAME"
    readonly INST_URL="${INST_URL-https://raw.githubusercontent.com/prantlf/$INST_NAME/master/$INST_NAME.sh}"
    start_debug "downloading $INST_URL"
    command curl -f $PROGRESS "$INST_URL" > "$SCRIPT" ||
        fail 'failed downloading' "$INST_URL to $SCRIPT"
    end_debug
    pass written "$SCRIPT"
    command chmod a+x "$SCRIPT" ||
        fail 'failed chaging mode' "of $SCRIPT to executable"
}

# write_env() {
#     local INST_ENV
#     INST_ENV="$INST_DIR/env"
#     echo "PATH=\"$NEW_PATH\"" > "$INST_ENV"
#     pass written "$INST_ENV"
# }

populate_installer_directory() {
    check_mkdir_exists
    check_curl_exists
    check_chmod_exists
    create_directory "$INST_DIR"
    download_installer
    # write_env
}

declare SHRC
declare FISH=0

determine_current_shell_rc() {
    local SH_VER
    SH_VER=$($SHELL -c "echo \$BASH_VERSION")
    if [ -n "$SH_VER" ]; then
        SHRC="$HOME/.bashrc"
    else
        SH_VER=$($SHELL -c "echo \$ZSH_VERSION")
        if [ -n "$SH_VER" ]; then
            SHRC="$HOME/.zshrc"
        else
            SH_VER=$($SHELL -c "echo \$FISH_VERSION")
            if [ -n "$SH_VER" ]; then
                SHRC="$HOME/.config/fish/config.fish"
                FISH=1
            else
                ignore 'unrecognised shell' "needs you to extend the PATH: PATH=\"$NEW_PATH\""
                SHRC=
            fi
        fi
    fi
}

update_shell_rc() {
    local CONTENT
    if [ -f "$SHRC" ]; then
        CONTENT=$(<"$SHRC")
        PATH_CHECK=/\.$INST_NAME:
        if [[ ! "$CONTENT" =~ $PATH_CHECK ]]; then
            if [ $FISH -eq 0 ]; then
                echo "
export PATH=\"$NEW_PATH\"" >> "$SHRC"
            else
                echo "
set -xp PATH \"$NEW_PATH\"" >> "$SHRC"
            fi
            pass updated "$SHRC"
        else
            ignore 'no need to update' "$SHRC"
        fi
    else
        ignore 'not found' "$SHRC"
    fi
}

print_introduction() {
    echo ''
    if [ $FISH -eq 0 ]; then
        echo -e "Start a new shell or update this one: ${C_BOLD}export PATH=\"$NEW_PATH\"${C_RESET}"
    else
        echo -e "Start a new shell or update this one: ${C_BOLD}set -xp PATH \"$NEW_PATH\"${C_RESET}"
    fi
    echo -e "Continue by installing $LANG_NAME:           ${C_BOLD}$INST_NAME install latest${C_RESET}
Upgrade regularly:                    ${C_BOLD}$INST_NAME upgrade${C_RESET}
See usage instructions:               ${C_BOLD}$INST_NAME help${C_RESET}"
}

install_installer() {
    announce 'installing' "$INST_NAME $VERSION - upgrader and version manager for $LANG_NAME"
    populate_installer_directory
    determine_current_shell_rc
    if [ -n "$SHRC" ]; then
        update_shell_rc
    else
        ignore 'not detected' "bash, zsh or fish"
    fi
    announce 'done' ''
    if [[ "${NO_INSTRUCTIONS-}" == "" ]]; then
        print_introduction
    fi
    if [[ "${DO_UPGRADE-}" == "1" ]]; then
        exec "$INST_DIR/$INST_NAME" upgrade
    fi
}

readonly TASK="${1-}"
case $TASK in
help)
    print_usage_instructions
    ;;
version)
    print_installer_version
    ;;
'')
    install_installer
    ;;
*)
    fail 'unrecognised task' "$TASK"
    ;;
esac
