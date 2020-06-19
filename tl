#!/bin/sh
######################################################################
# AUTHOR  : Jefferson 'Slackjeff' Carneiro
# EMAIL   : jeffersoncarneiro@slackjeff.com.br
# PRG     : tl - Todo List
# DESC    : List, add and finish tasks. All of this stored in a
#           simple plain text file. Located at your home. WRITE POSIX
#           SHELL.
# LICENSE : GPLv2
######################################################################

#=================== VARS
PRG="$(basename $0)"
VERSION='1.0'
todo="${HOME}/.todo.txt"
fgr='\033[31;1m'
fgb='\033[34;1m'
fgend='\033[m'
#=================== TEST
test ! -e "$todo" && > "$todo"

#=================== FUNCTIONS
USAGE(){ # Help
    cat << EOF
$PRG - $VERSION
USE: $PRG [OPTION] task
List, add and finish tasks. All of this stored in a simple plain text file.


  @    -  Show all task.
  add  -  Add a task. You can use a tag like @study
  end  -  A pattern is used to do the removal,
          including the tag if it exists. Example:
          $PRG end @goschool or pattern $PRG end beach
  help -  Show this help and exit.
EOF
}

SEND(){ # Send to todo.txt
    local receive="$@"

    # Send arg for todo.txt in HOME.
    printf '%s\n' "$receive" >> "$todo"
    return 0
}

SHOW(){ # Show all todo.txt
    local symbol="▶"
    while IFS= read _line_; do
       printf '%b\n' "${fgb}${symbol}${fgend} $_line_"
    done < "$todo"
    return 0
}

END(){
    local arg="$@"
    local temp="${todo}.tmp"

    # Search task and test if exist.
    local arg_test=$(grep "$arg" "$todo")
    [ -z "$arg_test" ] && { printf '%b\n' "${fgr}No task found...${fgend}";exit 1 ;}
    if sed "/$arg/d" "$todo" > $temp; then
       mv "$temp" "$todo" > /dev/null 2> /dev/null
       printf "%b\n" "Task Number: ${fgb}[$arg]${fgend} END."
       return 0
    fi
}

# Args in line =)
case $1 in
    *|help) USAGE; exit 0 ;;
    add)
      shift
      test -z "$@" 2> /dev/null && { printf '%s\n' "Need a task bro."; exit 1 ;}
      SEND "$@"
    ;;
    @)   shift; SHOW ;;
    end) shift; END "$@" ;;
esac