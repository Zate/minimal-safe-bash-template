#!/usr/bin/env bash
#: Your comments here.

set -o errexit
set -o nounset
set -o pipefail

work_dir=$(dirname "$(readlink --canonicalize-existing "${0}" 2> /dev/null)")
readonly conf_file="${work_dir}/script.conf"
readonly error_reading_conf_file=80
readonly error_parsing_options=81
readonly script_name="${0##*/}"
a_option_flag=0
abc_option_flag=0
flag_option_flag=0

trap clean_up ERR EXIT SIGINT SIGTERM

usage() {
    cat <<EOF
Usage: ${script_name} [-h | --help] [-a <ARG>] [--abc <ARG>] [-f]

DESCRIPTION
    Your description here.

    OPTIONS:

    -h, --help
        Print this help and exit.

    -f, --flag
        Description for flag option.

    -a
        Description for the -a option.

    --abc
        Description for the --abc option.

EOF
}

clean_up() {
    trap - ERR EXIT SIGINT SIGTERM
    # Remove temporary files/directories, log files or rollback changes.
}

die() {
    local -r msg="${1}"
    local -r code="${2-1}"
    echo "${msg}" >&2
    exit "${code}"
}

opts=$(getopt --options a:,f,h --long abc:,flag,help -- "${@}" 2> /dev/null) || {
    usage
    die "error: parsing options" "${error_parsing_options}"
}


if [[ ! -f "${conf_file}" ]]; then
    die "error reading configuration file: ${conf_file}" "${error_reading_conf_file}"
fi

eval set -- "${opts}"

while true; do
    case "${1}" in

        --abc)
            abc_option_flag=1
            readonly abc_arg="${2}"
            shift
            shift
            ;;

        -a)
            a_option_flag=1
            readonly a_arg="${2}"
            shift
            shift
            ;;

        --help|-h)
            usage

            exit 0
            shift
            ;;

        --flag|-f)
            flag_option_flag=1

            shift
            ;;

        --)
            shift
            break
            ;;
        *)
            break
            ;;
    esac
done

if ((flag_option_flag)); then
    echo "flag option set"
fi

if ((abc_option_flag)); then            # Check if the flag options are set or ON:
    # Logic for when --abc is set.
    # "${abc_arg}" should also be set.
    echo "abc option set"
    echo "Arg: [${abc_arg}]"
fi

if ((a_option_flag)); then
    # Logic for when -a is set.
    # "${a_arg}" should also be set.
    echo "a option set"
    echo "Arg: [${a_arg}]"
fi

exit 0