# Bash (tab) completion script for sr3_tools

SARRA_COMPONENTS="cpost flow poll post watch sarra sender shovel subscribe winnow"
SARRA_COMPONENTS_RE="^(${SARRA_COMPONENTS// /|})\$"
SR3_ACTIONS="cleanup declare disable enable list restart run sanity setup show start status stop"

###
# component_config
# 
# Generate component/config completion
#
# Separator is configurable so the same code can be reused for
# logs (component_configname) and sr3d (component/config)
#
# Potential completions:
#   - ${component}${sep} prefix
#   - ${component}${sep} + config file names, excluding .conf
#       either from ${PWD} or from ${PWD}/${component}
#
# Arguments:
#   $1 = the separator character (should be _ or /)
###
component_config()
{
    sep="$1"
    pwd_before="${PWD}"
    cdir="${PWD##*/}"
    
    # Config file name case, when the user already has the full ${component}${sep} (and maybe part of 
    # the config file name) in their COMP_CWORD
    # Must be the full component name and sep. 

    # cut off everything from the current word after and including $sep
    maybe_component=${COMP_WORDS[${COMP_CWORD}]%%${sep}*}
    if [[ "${maybe_component}" =~ ${SARRA_COMPONENTS_RE} ]] && [[ "${COMP_WORDS[${COMP_CWORD}]}" == "${maybe_component}${sep}"* ]]; then
        # when the user is one level up from the $component config directory, but they
        # have ${component}${sep}, cd to that directory then complete using config files inside
        if [[ "${SARRA_COMPONENTS}" != *"${cdir}"* ]]; then
            #maybe_component=${COMP_WORDS[${COMP_CWORD}]%%${sep}*}
            if [[ "${SARRA_COMPONENTS}" == *"${maybe_component}"* ]] && \
               [ -d "${maybe_component}" ]; then
                cd "${maybe_component}" || return
                cdir="${PWD##*/}"
            fi
        fi
        # part of current word after $component$sep
        current=${COMP_WORDS[${COMP_CWORD}]/"${cdir}${sep}"/""}
        # % to match at the end of the string, otherwise there will be issues with some config names
        # like a sender named send_to_dest or a poll named poll_this_source
        prefix=${COMP_WORDS[${COMP_CWORD}]/%"${current}"/""}
        mapfile -t tempreply < <(compgen -A file -X '!*.conf' -- "${current}")
        COMPREPLY=()
        for option in "${tempreply[@]}"; do
            # Could append _*.log here
            COMPREPLY+=("${prefix}${option%%.conf}")
        done
    
    # Case where there's no $component$sep prefix yet
    else
        # If inside a $component directory, use that.
        # when the pump name == a component name, this won't work.
        if [[ "${SARRA_COMPONENTS}" == *"${cdir}"* ]]; then
            # not really necessary, there shouldn't be more than one option, could set the reply to cdir
            mapfile -t tempreply < <(compgen -W "${cdir}" "${COMP_WORDS[${COMP_CWORD}]}")
        # Otherwise, offer all matching options
        else
            mapfile -t tempreply < <(compgen -W "${SARRA_COMPONENTS}" "${COMP_WORDS[${COMP_CWORD}]}")
        fi

        COMPREPLY=()
        for option in "${tempreply[@]}"; do
            COMPREPLY+=("${option}${sep}")
        done
    fi

    cd "${pwd_before}" || return
}


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
    else
        component_config '/'
    fi
}

complete -o nospace -F _sr3d sr3d

###
# sr3l
# See component_config function
###
_sr3l()
{
    component_config '_'
}

complete -o nospace -F _sr3l sr3l

###
# sr3_commit
# Complete using modified file paths in the Git repo
# Currently ignores the -m/--message option
###
_sr3_commit()
{
    mapfile -t tempreply < <(compgen -W "$(git ls-files -m -o)"  "${COMP_WORDS[${COMP_CWORD}]}")
    COMPREPLY=()
    for option in "${tempreply[@]}"; do
        if [[ "${COMP_LINE}" != *"${option}"* ]] ; then
            COMPREPLY+=("${option} ")
        fi
    done
}
complete -o nospace -F _sr3_commit sr3_commit

