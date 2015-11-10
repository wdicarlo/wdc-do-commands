# bash completion for GNU make                             -*- shell-script -*-

function _make_target_extract_script()
{
    local mode="$1"
    shift

    local prefix="$1"
    local prefix_pat=$( printf "%s\n" "$prefix" | \
                        sed 's/[][\,.*^$(){}?+|/]/\\&/g' )
    local basename=${prefix##*/}
    local dirname_len=$(( ${#prefix} - ${#basename} ))

    if [[ $mode == -d ]]; then
        # display mode, only output current path component to the next slash
        local output="\2"
    else
        # completion mode, output full path to the next slash
        local output="\1\2"
    fi

    cat <<EOF
    1,/^# Files/                  d;            # skip until files section
    /^# Not a target/,/^$/        d;            # skip not target blocks
    /^${prefix_pat}/,/^$/!        d;            # skip anything user dont want

    # The stuff above here describes lines that are not
    #  explicit targets or not targets other than special ones
    # The stuff below here decides whether an explicit target
    #  should be output.

    /^# File is an intermediate prerequisite/ {
      s/^.*$//;x;                               # unhold target
      d;                                        # delete line
    }

    /^$/ {                                      # end of target block
      x;                                        # unhold target
      /^$/d;                                    # dont print blanks
      s|^\(.\{${dirname_len}\}\)\(.\{${#basename}\}[^:/]*/\{0,1\}\)[^:]*:.*$|${output}|p;
      d;                                        # hide any bugs
    }

    # This pattern includes a literal tab character as \t is not a portable
    # representation and fails with BSD sed
    /^[^#	:%]\{1,\}:/ {         # found target block
      /^\.PHONY:/                 d;            # special target
      /^\.SUFFIXES:/              d;            # special target
      /^\.DEFAULT:/               d;            # special target
      /^\.PRECIOUS:/              d;            # special target
      /^\.INTERMEDIATE:/          d;            # special target
      /^\.SECONDARY:/             d;            # special target
      /^\.SECONDEXPANSION:/       d;            # special target
      /^\.DELETE_ON_ERROR:/       d;            # special target
      /^\.IGNORE:/                d;            # special target
      /^\.LOW_RESOLUTION_TIME:/   d;            # special target
      /^\.SILENT:/                d;            # special target
      /^\.EXPORT_ALL_VARIABLES:/  d;            # special target
      /^\.NOTPARALLEL:/           d;            # special target
      /^\.ONESHELL:/              d;            # special target
      /^\.POSIX:/                 d;            # special target
      /^\.NOEXPORT:/              d;            # special target
      /^\.MAKE:/                  d;            # special target

      /^[^a-zA-Z0-9]/             d;            # convention for hidden tgt

      h;                                        # hold target
      d;                                        # delete line
    }

EOF
}

# This function splits $cur=--foo=bar into $prev=--foo, $cur=bar, making it
# easier to support both "--foo bar" and "--foo=bar" style completions.
# `=' should have been removed from COMP_WORDBREAKS when setting $cur for
# this to be useful.
# Returns 0 if current option was split, 1 otherwise.
#
_split_longopt()
{
    if [[ "$cur" == --?*=* ]]; then
        # Cut also backslash before '=' in case it ended up there
        # for some reason.
        prev="${cur%%?(\\)=*}"
        cur="${cur#*=}"
        return 0
    fi

    return 1
}

# Initialize completion and deal with various general things: do file
# and variable completion where appropriate, and adjust prev, words,
# and cword as if no redirections exist so that completions do not
# need to deal with them.  Before calling this function, make sure
# cur, prev, words, and cword are local, ditto split if you use -s.
#
# Options:
#     -n EXCLUDE  Passed to _get_comp_words_by_ref -n with redirection chars
#     -e XSPEC    Passed to _filedir as first arg for stderr redirections
#     -o XSPEC    Passed to _filedir as first arg for other output redirections
#     -i XSPEC    Passed to _filedir as first arg for stdin redirections
#     -s          Split long options with _split_longopt, implies -n =
# @return  True (0) if completion needs further processing, 
#          False (> 0) no further processing is necessary.
#
_init_completion()
{
    local exclude flag outx errx inx OPTIND=1

    while getopts "n:e:o:i:s" flag "$@"; do
        case $flag in
            n) exclude+=$OPTARG ;;
            e) errx=$OPTARG ;;
            o) outx=$OPTARG ;;
            i) inx=$OPTARG ;;
            s) split=false ; exclude+== ;;
        esac
    done

    # For some reason completion functions are not invoked at all by
    # bash (at least as of 4.1.7) after the command line contains an
    # ampersand so we don't get a chance to deal with redirections
    # containing them, but if we did, hopefully the below would also
    # do the right thing with them...

    COMPREPLY=()
    local redir="@(?([0-9])<|?([0-9&])>?(>)|>&)"
    _get_comp_words_by_ref -n "$exclude<>&" cur prev words cword

    # Complete variable names.
    if [[ $cur =~ ^(\$\{?)([A-Za-z0-9_]*)$ ]]; then
        [[ $cur == *{* ]] && local suffix=} || local suffix=
        COMPREPLY=( $( compgen -P ${BASH_REMATCH[1]} -S "$suffix" -v -- \
            "${BASH_REMATCH[2]}" ) )
        return 1
    fi

    # Complete on files if current is a redirect possibly followed by a
    # filename, e.g. ">foo", or previous is a "bare" redirect, e.g. ">".
    if [[ $cur == $redir* || $prev == $redir ]]; then
        local xspec
        case $cur in
            2'>'*) xspec=$errx ;;
            *'>'*) xspec=$outx ;;
            *'<'*) xspec=$inx ;;
            *)
                case $prev in
                    2'>'*) xspec=$errx ;;
                    *'>'*) xspec=$outx ;;
                    *'<'*) xspec=$inx ;;
                esac
                ;;
        esac
        cur="${cur##$redir}"
        _filedir $xspec
        return 1
    fi

    # Remove all redirections so completions don't have to deal with them.
    local i skip
    for (( i=1; i < ${#words[@]}; )); do
        if [[ ${words[i]} == $redir* ]]; then
            # If "bare" redirect, remove also the next word (skip=2).
            [[ ${words[i]} == $redir ]] && skip=2 || skip=1
            words=( "${words[@]:0:i}" "${words[@]:i+skip}" )
            [[ $i -le $cword ]] && cword=$(( cword - skip ))
        else
            i=$(( ++i ))
        fi
    done

    [[ $cword -eq 0 ]] && return 1
    prev=${words[cword-1]}

    [[ $split ]] && _split_longopt && split=true

    return 0
}

_make()
{
    local cur prev words cword split
    _init_completion -s || return
    #if declare -F _init_completions >/dev/null 2>&1; then
    #    _init_completion
    #else
    #    __my_init_completion
    #fi
    local file makef makef_dir=( "-C" "." ) makef_inc i

    case $prev in
        -f|--file|--makefile|-o|--old-file|--assume-old|-W|--what-if|\
        --new-file|--assume-new)
            _filedir
            return 0
            ;;
        -I|--include-dir|-C|--directory|-m)
            _filedir -d
            return 0
            ;;
        -E)
            COMPREPLY=( $( compgen -v -- "$cur" ) )
            return 0
            ;;
        --eval|-D|-V|-x)
            return 0
            ;;
        --jobs|-j)
            COMPREPLY=( $( compgen -W "{1..$(( $(_ncpus)*2 ))}" -- "$cur" ) )
            return 0
            ;;
    esac

    $split && return 0

    if [[ "$cur" == -* ]]; then
        local opts="$( _parse_help "$1" )"
        [[ $opts ]] || opts="$( _parse_usage "$1" )"
        COMPREPLY=( $( compgen -W "$opts" -- "$cur" ) )
        [[ $COMPREPLY == *= ]] && compopt -o nospace
    elif [[ $cur == *=* ]]; then
        prev=${cur%%=*}
        cur=${cur#*=}
        local diropt
        [[ ${prev,,} == *dir?(ectory) ]] && diropt=-d
        _filedir $diropt
    else
        # before we check for makefiles, see if a path was specified
        # with -C/--directory
        for (( i=0; i < ${#words[@]}; i++ )); do
            if [[ ${words[i]} == -@(C|-directory) ]]; then
                # eval for tilde expansion
                eval makef_dir=( -C "${words[i+1]}" )
                break
            fi
        done

        # before we scan for targets, see if a Makefile name was
        # specified with -f/--file/--makefile
        for (( i=0; i < ${#words[@]}; i++ )); do
            if [[ ${words[i]} == -@(f|-?(make)file) ]]; then
                # eval for tilde expansion
                eval makef=( -f "${words[i+1]}" )
                break
            fi
        done

        # recognise that possible completions are only going to be displayed
        # so only the base name is shown
        local mode=--
        if (( COMP_TYPE != 9 )); then
            mode=-d # display-only mode
        fi

        local reset=$( set +o | command grep -F posix ); set +o posix # <(...)
        COMPREPLY=( $( LC_ALL=C \
            make -npq "${makef[@]}" "${makef_dir[@]}" .DEFAULT 2>/dev/null | \
            sed -nf <(_make_target_extract_script $mode "$cur") ) )
        $reset

        if [[ $mode != -d ]]; then
            # Completion will occur if there is only one suggestion
            # so set options for completion based on the first one
            [[ $COMPREPLY == */ ]] && compopt -o nospace
        fi

    fi
} &&
complete -F _make make gmake gnumake pmake colormake

# ex: ts=4 sw=4 et filetype=sh
