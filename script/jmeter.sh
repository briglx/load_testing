#!/usr/bin/env bash

# Stop on errors
set -eu

show_help() {
    echo "$0 : Edit and run jmeter scripts."
    echo "Usage: jmeter.sh [COMMAND] [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help                      show this messagea and get help for a command"
    echo "  -p, --propfile <argument>       jmeter property file to use"
    echo "  -t, --testfile <argument>       jmeter test file"
    echo "  -l, --logfile <argument>        the file to log samples to"

    echo "Commands"
    echo "  run             Run a test script in NON_GUI mode."
    echo "                    -t test-file"
    echo "  edit            Edit a test script in GUI mode."
    echo "                    -t test-file"
    echo "Example usage:"
    echo "  $0 run -t ./load_tests/test_plan.jmx"
    echo "  $0 edit -t ./load_tests/test_plan.jmx"
}

validate_general_parameters(){
    # Check command
    if [ -z "$1" ]
    then
        echo "COMMAND is required (run | edit)" >&2
        show_help
        exit 1
    fi

    # Check command is either run or edit
    if [ "$1" != "run" ] && [ "$1" != "edit" ]
    then
        echo "Invalid COMMAND" >&2
        show_help
        exit 1
    fi

     # Check testfile
    if [ -z "$testfile" ]
    then
        echo "Test file is required" >&2
        show_help
        exit 1
    fi

     # Check if testfile exists
    if [ ! -f "$testfile" ]
    then
        echo "Test file does not exist" >&2
        show_help
        exit 1
    fi

    # Check logfile
    if [ -z "$logfile" ]
    then
        echo "Log file is required" >&2
        show_help
        exit 1
    fi

    # Check jmeter directory
    if [ ! -d "$JMETER_DIR" ]
    then
        echo "Jmeter directory does not exist. Ensure JMETER_DIR env var is set to /path/to/jmeter-version" >&2
        show_help
        exit 1
    fi

    # Check if jmeter file exists
    if [ ! -f "${JMETER_DIR}/bin/jmeter" ]
    then
        echo "jmeter file not found. Ensure JMETER_DIR env var is set to /path/to/jmeter-version" >&2
        show_help
        exit 1
    fi

}

run(){
    local propfile="$propfile"

    if [ -z "$propfile" ]
    then
       propfile="$TEST_DIRECTORY/run.properties"
    fi

    echo "Running test file: $testfile with $propfile" >&2

    export JVM_ARGS="${JVM_ARGS}"
    "${JMETER_DIR}/bin/jmeter" \
        --nongui \
        --testfile "$testfile" \
        --logfile "$logfile" \
        --propfile "$propfile" \
        --reportatendofloadtests \
        --reportoutputfolder "${TEST_DIRECTORY}/report/${RUN_DATE}"
}

edit(){
    local propfile="$propfile"

    if [ -z "$propfile" ]
    then
       propfile="$TEST_DIRECTORY/user.properties"
    fi

    echo "Editing file: $testfile with $propfile" >&2

    # export JVM_ARGS="${JVM_ARGS}"
    export JVM_ARGS="${JVM_GUI_ARGS}"
    "${JMETER_DIR}/bin/jmeter" \
        --testfile "$testfile" \
        --logfile "$logfile" \
        --propfile "$propfile"
}

# Globals
PROJ_ROOT_PATH=$(cd "$(dirname "$0")"/..; pwd)
echo "Project root: $PROJ_ROOT_PATH"  >&2
TEST_DIRECTORY="${PROJ_ROOT_PATH}/load_tests"
JVM_ARGS="-Xms1G -Xmx10G -Dnashorn.args=--no-deprecation-warning"
JVM_GUI_ARGS="-Dawt.useSystemAAFontSettings=lcd_hrgb ${JVM_ARGS}"
RUN_DATE=$(date +%Y%m%dT%H%M%S)

# Argument/Options
LONGOPTS=propfile:,testfile:,logfile:,help
OPTIONS=p:t:l:h

# Variables
propfile=""
testfile=""
logfile="$TEST_DIRECTORY/log/${RUN_DATE}.csv"

# Parse arguments
TEMP=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
eval set -- "$TEMP"
unset TEMP
while true; do
    case "$1" in
        -p|--propfile)
            propfile=$2
            shift 2
            ;;
        -t|--testfile)
            testfile=$2
            shift 2
            ;;
        -l|--logfile)
            logfile=$2
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unknown parameter."
            show_help
            exit 1
            ;;
    esac
done

validate_general_parameters "$@"
command=$1
case "$command" in
    edit)
        edit
        exit 0
        ;;
    run)
        run
        exit 0
        ;;
    *)
        echo "Unknown command."
        show_help
        exit 1
        ;;
esac
