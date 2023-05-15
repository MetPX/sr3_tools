# Bash (tab) completion script for sr3_tools

SARRA_COMPONENTS="cpost flow poll post watch sarra sender shovel subscribe winnow"
SR3_ACTIONS="cleanup declare disable enable list restart run sanity setup show start status stop"

###
# sr3d
# Possible actions: https://metpx.github.io/sarracenia/Reference/sr3.1.html#actions
# sr3d syntax is the same as sr3:
#     sr3d action [component/config]
# except some actions (edit, foreground, etc.) don't make sense on a cluster
###
_sr3d()
{
    # action argument
    if [ "${COMP_CWORD}" == 1 ]; then
        mapfile -t tempreply < <(compgen -W "${SR3_ACTIONS}" "${COMP_WORDS[${COMP_CWORD}]}")
        COMPREPLY=()
        for option in "${tempreply[@]}"; do
            COMPREPLY+=("${option} ")
        done
    fi
    # component/config argument
    if [ "${COMP_CWORD}" == 2 ]; then
        mapfile -t tempreply < <(compgen -W "${SARRA_COMPONENTS}" "${COMP_WORDS[${COMP_CWORD}]}")
        COMPREPLY=()
        for option in "${tempreply[@]}"; do
            COMPREPLY+=("${option}/")
        done
    fi
}

complete -o nospace -F _sr3d sr3d

###
# sr3l
# Potential completions:
#   - the current $component directory (log file prefix)
#   - the name of a config file from the current or $component directory
###
_sr3l()
{
    pwd_before="${PWD}"
    # Component prefix case
    cdir="${PWD##*/}"
    if [[ "${SARRA_COMPONENTS}" == *"${cdir}"* ]] && \
       [[ "${COMP_LINE}" != *"${cdir}"* ]]; then
        mapfile -t tempreply < <(compgen -W "${cdir}" "${COMP_WORDS[${COMP_CWORD}]}")
        COMPREPLY=()
        # Loop isn't really necessary, there shouldn't be more than one option
        for option in "${tempreply[@]}"; do
            COMPREPLY+=("${option}_")
        done
    # Config file name case
    else
        # when the user is one level up from the $component config directory, but
        # they've manually typed $component_, complete from config files in that directory
        if [[ "${SARRA_COMPONENTS}" != *"${cdir}"* ]]; then 
            maybe_component=${COMP_WORDS[${COMP_CWORD}]%%_*}
            if [[ "${SARRA_COMPONENTS}" == *"${maybe_component}"* ]] && \
               [ -d "${maybe_component}" ]; then
                cd "${maybe_component}" || return
                cdir="${PWD##*/}"
            fi
        fi
        
        current=${COMP_WORDS[${COMP_CWORD}]/"${cdir}_"/""}
        # % to match at the end of the string, otherwise there will be issues with some config names
        # like a sender named send_to_dest or a poll named poll_this_source
        prefix=${COMP_WORDS[${COMP_CWORD}]/%"${current}"/""}
        mapfile -t tempreply < <(compgen -A file -X '!*.conf' -- "${current}")
        COMPREPLY=()
        for option in "${tempreply[@]}"; do
            # Could append _*.log here
            COMPREPLY+=("${prefix}${option%%.conf}")
        done
    fi
    cd "${pwd_before}" || return
}

complete -o nospace -F _sr3l sr3l
