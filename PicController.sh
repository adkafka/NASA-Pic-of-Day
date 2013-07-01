#!/bin/bash
#This script checks to see if a file exists, if it does it will execute a script.



PATHCHECK="/Users/Adam/Desktop/NasaDailyPics/"
PREFIX=`date "+%Y-%m-%d"`
LOG=`echo "${HOME}/Library/Logs/NasaPic.log"`
SCRIPTPATH="/Users/Adam/Projects/NASAPicOfDay/GrapPicOfDay.sh"
PLACEHOLDER="PLACEHOLDER"

if [ ! -f ${LOG} ]; then #Test if this is first entry to log file
	echo "Beginning Nasa Daily Photo grab script writen by Adam Kafka" >>$LOG
fi

echo "---------`date`----------">>${LOG}
echo "Running Controller script">>${LOG}

#If placeholder files exist in directory, delete them

FILESTODELETE=`ls ${PATHCHECK} | grep ${PLACEHOLDER} | grep -v ${PREFIX}`
if [ $? -eq 0 ]; then
	echo "Removing old placheolder files...">>${LOG}
	for FILE in $FILESTODELETE; do
		FILE=${PATHCHECK}${FILE}
		echo "Permanently deleting ${FILE}">>${LOG}
		rm ${FILE}
	done
fi

FILECHECK=${PATHCHECK}${PREFIX} #Beginning of file name that will be created by other script

if [ -f ${FILECHECK}* ]; then
	echo "File ${FILECHECK} exists, no need to run script">>${LOG} #Check if higher quality image available?
	echo "-----------------------------------------------">>${LOG}
else
	echo "File ${FILECHECK} does not already exist, running grab script now">>${LOG}
	bash ${SCRIPTPATH}
	SCRIPTEXIT=$? #Set this variable to the exit status of the script. 1 for no file found
	if [  ${SCRIPTEXIT} -eq 0 ]; then
		echo "Script seemed to have run succesfully. Exited with status 0">>${LOG}
		echo "-----------------------------------------------">>${LOG}
	elif [ ${SCRIPTEXIT} -eq 1 ]; then
		echo "Exited script with exit status 1. Will try again next time.">>${LOG}
		echo "-----------------------------------------------">>${LOG}

	elif [ ${SCRIPTEXIT} -eq 2 ];then
		echo "Exited script with exit status 2, Creating placeholder file">>${LOG}
		touch ${FILECHECK}${PLACEHOLDER} #Create placeholder file
		echo "-----------------------------------------------">>${LOG}
	else
		echo "Script exited with exit status not equal to 0, 1, or 2"

	fi
		
fi


