#!/bin/sh

help() {
    echo "\nUSAGE:\n$1 [-d] [-s <scenario>] [-p <port_number>]\n
-d\n   enable debug mode\n
-s <scenario>\n   run the scenario after starting the controller\n
-p <port_number>\n   listen on the specified port number"
}


parse_opts() {
    while getopts ":ds:p:" OPT
    do
        case $OPT in
            d)
                DEBUG=true
                ;;
            s)
                SCENARIO=${OPTARG}
                ;;
            p)
                PORT=${OPTARG}
                if ! [  "$PORT" -eq "$PORT" ] 2>/dev/null; then
                    echo "The argument for -${OPT} has to be an integer"
                    help $0
                    exit 1
                fi
                ;;
            \?)
                echo "Invalid option: -${OPTARG}"
                help $0
                exit 1
                ;;
            :)
                echo "Option -${OPTARG} requires an argument"
                help $0
                exit 1
                ;;
        esac
    done
}

run_controller() {
    erlc of_controller_v4.erl -pa ../deps/*/ebin -pa ../apps/*/ebin

    if [ -z ${SCENARIO} ]; then
        ERL_EVAL="of_controller_v4:start(${PORT})"
    else
        if [ -z ${PORT} ]; then
            START_ARGS="${SCENARIO}"
        else
            START_ARGS="${PORT}, ${SCENARIO}"
        fi
        ERL_EVAL="of_controller_v4:start_scenario(${START_ARGS})"
    fi

    if  [ -z ${DEBUG} ]; then
        ERL_EVAL=${ERL_EVAL}"."
    else
        ERL_EVAL=${ERL_EVAL}", lager:set_loglevel(lager_console_backend, debug)."
    fi

    erl -pa ../deps/*/ebin -eval "`echo ${ERL_EVAL}`"
}

parse_opts $@
run_controller
