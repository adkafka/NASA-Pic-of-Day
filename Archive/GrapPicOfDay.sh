#!/bin/bash
#This script goes to URL and grabs the highest resolution pic and puts it in DESTINATION
#Exit 0=seemingle succesful
#Exit 1=wget failed
#Exit 2=No 

#Constants
DIRPATH=`echo "/tmp/PicOfDay-$RANDOM"` #Random file in temp dir
ACCEPTLIST="jpg,gif"
DESTINATION="/Users/Adam/Desktop/Projects/NASAPicOfDay/Archive/Output/" #Must end in / (a trailing backslash)

if [ "$#" -eq 2 ];then #If two paramaters are supplied
	URL=$1
	DATE_FN=$2
else
	echo "Invalid input"
	echo "Input should be ./GrabPicOfDay URL date(yyyy-mm-dd)"
	exit 1

fi

mkdir ${DIRPATH} #Make temp directory to work in
cd ${DIRPATH} #cd into temp irectory

function exitSuccess(){ #Exit the script succesfully
	rm -r ${DIRPATH} #CleanUp directory

	echo "[+] Script Complete on `date`"
	echo "-----------------------------------------------"
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
		echo "Unable to connect to ${URL}, wget exited with exit status 4. Exit with error status 1"
		rm -r ${DIRPATH} #CleanUp directory
		exit 1 #wget failed to connect
	fi

	NUMFILES=`ls | wc -l | tr -d ' '` #Gets how many files are in the directory

	if [ "${NUMFILES}" -lt "1" ]; then #If there are no files in the dir after wget, exit with error status 1
		echo "Error, no file of filetype ${ACCEPTLIST} found"
		echo "Checking for video"
		CheckVideo
	fi

	HQIMAGENAME=`BiggestFile` #Get largest file's name
	HQDEST=`echo "${DESTINATION}${DATE_FN}-${HQIMAGENAME}"` #Moves best quality file to destination

	echo "[+]Moving best image ${HQIMAGE} from tmp dir to ${HQDEST}"
	mv ${HQIMAGENAME} ${HQDEST}

	exitSuccess #Exit the program succesfully

}

function CheckVideo(){
	TEMPNAME=$RANDOM

	wget ${URL} --quiet
	FILENAME=`ls`
	
	LINKS=`cat ${FILENAME} | grep iframe` #Get only the iframe line
	LINKS=`echo $LINKS  | sed 's/.*src="//g'` #Take out the junk, everything before link
	LINKS=`echo $LINKS | sed 's/" .*//g'` #Take out everything after the link. Now it is just the link
	NUMLINES=`echo $LINKS | wc -l`
	if [ "${NUMLINES}" -ge "1" ]; then #Tests if there are any succesful 
		#For loop for youtube-dl
		for LINK in $LINKS; do
			echo "Downloading ${LINK}"
			youtube-dl -o '%(title)s.%(ext)s' --restrict-filenames ${LINK}
		done
		HQVID=`BiggestFile`
		#HQVID=`echo "${HQIMAGE}"`
		HQDEST=`echo "${DESTINATION}${DATE_FN}-${HQVID}"`
		
		echo "[+] -Moving best video ${HQVID} from tmp dir to ${HQDEST}"
		mv ${HQVID} ${HQDEST}
		exitSuccess
		
	else #Executed when no video link is found
		echo "No link to video found"
		rm -r ${DIRPATH} #CleanUp directory	
		exit 2 #No suitable files found after succesful wget and Video check
	fi


}


echo "[+] - Getting Media"
GrabImage #Grabs image of the day, if none, runs CheckVideo
exit 0 #Should never get here. All other permutations have an exit
