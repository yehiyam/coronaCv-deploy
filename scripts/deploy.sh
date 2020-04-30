#!/usr/bin/env bash
{ # this ensures the entire script is downloaded #
    
    set -euo pipefail
    printf "\n"
    
    BOLD="$(tput bold 2>/dev/null || echo '')"
    GREY="$(tput setaf 0 2>/dev/null || echo '')"
    UNDERLINE="$(tput smul 2>/dev/null || echo '')"
    RED="$(tput setaf 1 2>/dev/null || echo '')"
    GREEN="$(tput setaf 2 2>/dev/null || echo '')"
    YELLOW="$(tput setaf 3 2>/dev/null || echo '')"
    BLUE="$(tput setaf 4 2>/dev/null || echo '')"
    MAGENTA="$(tput setaf 5 2>/dev/null || echo '')"
    NO_COLOR="$(tput sgr0 2>/dev/null || echo '')"
    
    info() {
        printf "${BOLD}${GREY}>${NO_COLOR} $@\n"
    }
    
    warn() {
        printf "${YELLOW}! $@${NO_COLOR}\n"
    }
    
    error() {
        printf "${RED}x $@${NO_COLOR}\n" >&2
    }
    
    complete() {
        printf "${GREEN}✓${NO_COLOR} $@\n"
    }
    
    REPOSITORY_NAME="coronaCv-deploy"
    CLONE_URL="https://github.com/yehiyam/${REPOSITORY_NAME}.git"
    
    function command_exists {
        #this should be a very portable way of checking if something is on the path
        #usage: "if command_exists foo; then echo it exists; fi"
        hash "$1" &> /dev/null
    }
    
    fetch() {
        local command
        if hash curl 2>/dev/null; then
            set +e
            command="curl --silent --fail --location $1"
            curl  --fail  --location "$1"
            rc=$?
            set -e
        else
            if hash wget 2>/dev/null; then
                set +e
                command="wget -O- -q --show-progress  $1"
                wget -O- -q --show-progress "$1"
                rc=$?
                set -e
            else
                error "No HTTP download program (curl, wget) found…"
                exit 1
            fi
        fi
        
        if [ $rc -ne 0 ]; then
            printf "\n" >&2
            error "Command failed (exit code $rc): ${BLUE}${command}${NO_COLOR}"
            printf "\n" >&2
            exit $rc
        fi
    }
    
    function clone {
        if [[ ! -d ${REPOSITORY_NAME} ]]
        then
            echo ${REPOSITORY_NAME} does not exist. cloning now
            git clone ${CLONE_URL}
        else
            echo ${REPOSITORY_NAME} exists. skipping clone
        fi
        cd ${REPOSITORY_NAME}
    }
    
    function compose {
        info "Checking if docker-compose is installed: "
        if command_exists docker-compose
        then
            info Yes
        else
            warn No
            info "Installing docker-compose"
            local sudo
            local msg
            
            if [ -w "$BIN_DIR" ]; then
                sudo=""
                msg="Installing, please wait…"
            else
                warn "Escalated permission are required to install to ${BIN_DIR}"
                sudo -v || (error "Aborting installation (Please provide root password)";exit 1)
                sudo="sudo"
                msg="Installing as root, please wait…"
            fi
            URL="https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)"
            fetch "${URL}" \
            | ${sudo} tee "${BIN_DIR}/docker-compose" > /dev/null && sudo chmod +x "${BIN_DIR}/docker-compose"
        fi
        
    }
    
    info "Download and Install of corona monitor OCR"
    check_bin_dir() {
        local bin_dir="$1"
        
        # https://stackoverflow.com/a/11655875
        local good
        good=$( IFS=:
            for path in $PATH; do
                if [ "${path}" = "${bin_dir}" ]; then
                    echo 1
                    break
                fi
            done
        )
        
        if [ "${good}" != "1" ]; then
            warn "Bin directory ${bin_dir} is not in your \$PATH"
        fi
    }
    
    # defaults
    if [ -z "${BIN_DIR-}" ]; then
        BIN_DIR=/usr/local/bin
    fi
    
    # parse argv variables
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -b|--bin-dir) BIN_DIR="$2"; shift 2;;
            
            -V|--verbose) VERBOSE=1; shift 1;;
            -f|-y|--force|--yes) FORCE=1; shift 1;;
            
            -b=*|--bin-dir=*) BIN_DIR="${1#*=}"; shift 1;;
            -V=*|--verbose=*) VERBOSE="${1#*=}"; shift 1;;
            -f=*|-y=*|--force=*|--yes=*) FORCE="${1#*=}"; shift 1;;
            
            *) error "Unknown option: $1"; exit 1;;
        esac
    done
    
    printf "  ${UNDERLINE}Configuration${NO_COLOR}\n"
    info "${BOLD}Bin directory${NO_COLOR}: ${GREEN}${BIN_DIR}${NO_COLOR}"
    
    # non-empty VERBOSE enables verbose untarring
    if [ -n "${VERBOSE-}" ]; then
        VERBOSE=v
        info "${BOLD}Verbose${NO_COLOR}: yes"
    else
        VERBOSE=
    fi
    
    echo
    compose
    clone

} # this ensures the entire script is downloaded #
