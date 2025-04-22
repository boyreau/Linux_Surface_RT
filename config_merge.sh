#!/bin/bash

DEFCONF=$1
NEWCONF=$2
CONF=$3

if [ -z "$DEFCONF" ] || [ -z "$NEWCONF" ]
then
	echo "./config_merge.sh defconfig newconfig [outfile]"
	exit 1
fi
if [ -z "$CONF" ]
then
	CONF=.config
fi

echo "Using $DEFCONF as the default config."
echo "Using $NEWCONF as the newer config."
echo "Writing the merged config in $CONF."

cp -v $DEFCONF $CONF

while read -r line
do
	if [[ "$line" == "#*" ]]
	then
		continue
	fi

	OPTION=$(echo $line | cut -d'=' -f1)
	VALUE=$(echo $line | cut -d'=' -f2)

	# If the key is not in .config add it
	echo grep -q \"$OPTION=\" $CONF
	if [ $(grep -q "$OPTION=" $CONF) ]
	then
		echo $line >> $CONF
	fi

	# if the key is in .config but not as a module, make it a module
	if [[ "$VALUE" == "m" ]]
	then
		sed -i "s/$OPTION=y/$OPTION=m/g" $CONF
	fi
done < $NEWCONF
