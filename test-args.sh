#!/bin/bash

#usage=myscript.sh -p=my_prefix -s=dirname -l=libname

# Usage
# ---------------------------------------------------\
usage()
{
cat << EOF

Usage: $0 options

OPTIONS:
   -c      Create VirtualHost
   -r      Remove VirtualHost

Example: $0 -c vhost
   
EOF
}

	
	VHOST=""
    FLAG=""

    while [[ $# > 1 ]]
    do
    key="$1"
    shift

    case $key in
        -c|--create)
        VHOST="$1"
        FLAG="1"
        shift
        ;;
        -r|--remove)
        VHOST="$1"
        FLAG="2"
        shift
        ;;
    esac
    done

if [[ "$FLAG" == "" ]]
	then
	usage
fi

if [[ "$FLAG" == "1" ]]
	then
	echo "Creating $VHOST"
fi

if [[ "$FLAG" == "2" ]]
	then
	echo "Removing $VHOST"
fi


# for arg
# do
#     case "$arg" in
#         -dontbuild)
#             echo $1 $2 $3
#             ;;
#         -donttest)
#             do_something
#             ;;
#         -dontupdate)
#             do_something
#             ;;
#         -help)
#             note
#             ;;
#         *)
#             echo -e "\nUnknown argument"
#             note
#             exit 1
#             ;;
#      esac
# done

# for i in "$@"
# do
# case $i in
#     -p=*|--prefix=*)
#     PREFIX="${i#*=}"

#     ;;

#     -s=*|--searchpath=*)
#     SEARCHPATH="${i#*=}"
#     ;;

#     -l=*|--lib=*)
#     DIR="${i#*=}"
#     ;;

#     -n*|--note=*)
#     note

#     ;;

#     --default)
#     DEFAULT=YES
#     ;;

#     *)
#             # unknown option
#     ;;
# esac
# done
# echo PREFIX = ${PREFIX}
# echo SEARCH PATH = ${SEARCHPATH}
# echo DIRS = ${DIR}

