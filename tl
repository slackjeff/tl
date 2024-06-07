#!/bin/sh
######################################################################
# AUTHOR  : Jefferson 'Slackjeff' Carneiro
# EMAIL   : jeffersoncarneiro@slackjeff.com.br
# PRG     : tl - Todo List
# DESC    : List, add and finish tasks. All of this stored in a
#           simple plain text file. Located at your home. WRITE POSIX
#           SHELL.
# LICENSE : GPLv2
#
# ShellCheck [OK]
# https://www.shellcheck.net/wiki/SC2124
######################################################################

#=================== VARS
PRG="$(basename "$0")"
VERSION='2.0'
todo="${HOME}/.todo.txt"
fgr='\033[31;1m'
fgg='\033[32;1m'
fgb='\033[34;1m'
fgend='\033[m'
#=================== TEST
test ! -e "$todo" && true> "$todo" # Dont exist?

#=================== FUNCTIONS
USAGE(){ # Help
    cat << EOF
$PRG - Version $VERSION
USAGE: $PRG [OPTION] task
List, add and finish tasks. All of this stored in a simple plain text file
in your home.

[OPTIONS]
 list    -  List all task.
 add     -  Add a task. You can use a tag like @study @gym @buyfood
 end     -  A pattern is used to do the removal, including the tag
            if it exists. Examples:
             $PRG end "@goschool"
             $PRG end "beach"
             $PRG end "Go to gym"
 del-end -  Delete all END tasks.
 help    -  Show this help and exit.
EOF
	exit
}

SEND(){ # Send to todo.txt
    receive="$@"

    # Send arg for todo.txt in HOME.
    printf '%s\n' "$receive" >> "$todo"
    printf '%b\n' "${fgb}[ADDED]${fgend} $receive"
    return 0
}

SHOW(){ # Show all todo.txt
	inc=0
    while IFS= read -r line; do
    	if echo "$line" | grep -q "^:@"; then
    		line=${line##:@} # remove :@, its indicate end task.
    	    printf '%b\n' "${fgg}[X]${fgend}$line"
    	    continue
    	else
    	    printf '%b\n' "${fgr}[]${fgend} $line"
    	fi
    	inc=$((inc + 1))
    done < "$todo"

    # No tasks?
    if [ "$inc" -eq 0 ]; then
    	printf '%b\n' "${fgr}No tasks... is good news.${fgend} $line"
    fi
    return 0
}

END(){
    arg="$@"
    temp="${todo}.tmp"

	[ -z $arg ] && USAGE
    # Search task and test if exist.
    arg_test=$(grep "$arg" "$todo")
    [ -z "$arg_test" ] && { printf '%b\n' "${fgr}No task found...${fgend}";exit 1 ;}
    if sed "s/\(.*$arg.*\)/\:\@ \1/" "$todo" > "$temp"; then
       mv "$temp" "$todo" > /dev/null 2> /dev/null
       printf "%b\n" "Task ${fgb}[$arg]${fgend} END."
       return 0
    fi
}

# Remove all END tasks todo file.
DEL_END()
{
	if sed -i '/:@/d' "$todo"; then
		printf '%b\n' "${fgr}[EXCLUDE] All End tasks.${fgend}"
	fi
}


[ -z "$1" ] && USAGE
# Args in line =)
case $1 in
    help) USAGE; exit 0 ;;
    add)
      shift
      test -z "$@" 2> /dev/null && { printf '%s\n' "Need a task bro."; exit 1 ;}
      SEND "$@"
    ;;
    list|@)   shift; SHOW ;;
    end) shift; END "$@" ;;
    del-end) shift; DEL_END "$@" ;;
    *) USAGE; exit 0 ;;
esac
