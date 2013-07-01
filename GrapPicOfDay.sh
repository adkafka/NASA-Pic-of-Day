#!/bin/bash
#This script goes to URL and grabs the highest resolution pic and puts it in DESTINATION
#Exit 0=seemingle succesful
#Exit 1=wget failed
#Exit 2=No 

#STUFF TO ADD
#Email on fail to fix and make perfect


DIRPATH=`echo "/tmp/PicOfDay-$RANDOM"` #Random file in temp dir
ACCEPTLIST="jpg,gif"
URL="http://apod.nasa.gov/apod/astropix.html"
#URL="http://apod.nasa.gov/apod/ap130601.html" #used fro manually grabbing other pages
DESTINATION="/Users/Adam/Desktop/NasaDailyPics/" #Must end in / (a trailing backslash)
LOG=`echo "${HOME}/Library/Logs/NasaPic.log"`
DATE_FN=`date "+%Y-%m-%d"`
SCREENSAVER=/Users/Adam/Pictures/Screen\ Saver\ Pics

if [ "$#" -eq 2 ];then #If two paramaters are supplied
	URL=$1
	DATE_FN=$2
fi

mkdir ${DIRPATH} #Make temp directory to work in
cd ${DIRPATH} #cd into temp irectory

function exitSuccess(){ #Exit the script succesfully
	rm -r ${DIRPATH} #CleanUp directory

	echo "Script Complete on `date`">>${LOG}
	echo "-----------------------------------------------">>${LOG}
	exit 0 #Ran succesfully
	
}

function BiggestFile(){ #This function returns the name of the largest file in the dir
	HQIMAGE=`du -sck ./* | sort -nr | head -2 | tail -1 | awk '{print $2}'`; DUEXITSTATUS=`echo $?` #Returns largest file
###Creates a list of biggest files, sorts by size, biggest at bottom, takes out bottom two (total and wanted one), then top one (one we want), and prints the socnd arguement with awk.  
	echo "${HQIMAGE:2}" #Get rid of ./ in name and return file name
}

function GrabImage(){
	wget -r -np -nd  -N -l1 -A ${ACCEPTLIST} -erobots=off "${URL}" --quiet
	if [ $? -eq 4 ]; then #If internet doesnt work...
		echo "Unable to connect to ${URL}, wget exited with exit status 4. Exit with error status 1">>${LOG}
		rm -r ${DIRPATH} #CleanUp directory
		exit 1 #wget failed to connect
	fi

	NUMFILES=`ls | wc -l | tr -d ' '` #Gets how many files are in the directory

	if [ "${NUMFILES}" -lt "1" ]; then #If there are no files in the dir after wget, exit with error status 1
		echo "Error, no file of filetype ${ACCEPTLIST} found">>${LOG}
		echo "Checking for video">>${LOG}
		CheckVideo
	fi

	HQIMAGENAME=`BiggestFile` #Get largest file's name
	HQDEST=`echo "${DESTINATION}${DATE_FN}-${HQIMAGENAME}"` #Moves best quality file to destination

	echo "`date` - Linking file to Screen Saver dir & Moving best image ${HQIMAGE} from tmp dir to ${HQDEST}">>${LOG}
	mv ${HQIMAGENAME} ${HQDEST}
	ln  ${HQDEST}  "${SCREENSAVER}" #will occasionaly fail if destination already exists, will not occur outside of testing

	exitSuccess #Exit the program succesfully

}

function CheckVideo(){
	TEMPNAME=$RANDOM

	wget ${URL} --quiet
	FILENAME=`ls`
	
	LINKS=`cat ${FILENAME} | grep iframe` #Get only the iframe line
	LINKS=`echo $LINKS  | sed 's/.*src="//g'` #Take out the junk, everything before link
	LINKS=`echo $LINKS | sed 's/" .*//g'` #Take out everything after the link. Now it is just the link
	LINKS=`echo $LINKS | egrep -o '[A-z]*.com/.*'` #Make sure it is formatted correctly
	NUMLINES=`echo $LINKS | wc -l`
	rm ${FILENAME} #delete html files
	if [ "${NUMLINES}" -ge "1" ]; then #Tests if there are any succesful 
		#For loop for youtube-dl
		for LINK in $LINKS; do
			echo "Downloading ${LINK}">>${LOG}
			# The -f specifies which format to try to download. This will doenload the highest quality mp3
			youtube-dl "-f 38/37/84/22/85/82/83/18/17/35/34/5" -o '%(title)s.%(ext)s' --restrict-filenames ${LINK}>>${LOG}
		done
		HQVID=`BiggestFile`
		#HQVID=`echo "${HQIMAGE}"`
		HQDEST=`echo "${DESTINATION}${DATE_FN}-${HQVID}"`
		
		echo "`date` -Moving best video ${HQVID} from tmp dir to ${HQDEST}">>${LOG}
		mv ${HQVID} ${HQDEST}
		exitSuccess
		
	else #Executed when no video link is found
		echo "$NUMFILES -numfiles $LINKS -links"
		pwd
		ls
		echo "No link to video found">>${LOG}
		rm -r ${DIRPATH} #CleanUp directory	
		exit 2 #No suitable files found after succesful wget and Video check
	fi


}


echo "`date` - Getting Media">>${LOG}
GrabImage #Grabs image of the day, if none, runs CheckVideo
exit 0 #Should never get here. All other permutations have an exit
