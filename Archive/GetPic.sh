#!/bin/bash

#############
#CHECK INPUT#
#############

if [ -z $3 ]; then
	echo "Invalid Input"
	echo "Run script by entering ./GetUrl.sh Year Month(Spelled) Day"
	exit 1
fi

############
#PARAMETERS#
############

YEAR=$1
MONTH=$2
DAY=$3

###########
#FUNCTIONS#
###########

#Takes a date string as input and returns the url of a page 
function GetUrlFromDate() {
	LINE=`curl -s http://apod.nasa.gov/apod/archivepix.html | egrep "^${DATE}:.*$"`
	GETDATEEXITSTATUS=`echo $?`

	if [ $GETDATEEXITSTATUS -gt "0" ]; then
		echo "Error occured"
		echo "Invalid date input"
		echo "If date is After Jan 1 2000: Input should be \"YYYY Month DD \""
		echo "If date is before 2000, Input should be similar to \"Month DD YYYY"
		echo ""
		echo "Make sure month is spelled corectly and if day of month is less than 10, it is preceeded by a 0"
		exit 2
	fi

	FILE=`echo $LINE | egrep -o "ap[0-9]{6}.html"`
	URL=`echo "http://apod.nasa.gov/apod/$FILE"`
	echo "$URL"
}

#Takes year, month, day and generates a numeric date as yyyy-mm-dd
function GenerateDateNum () {
	DATENUM=`echo "$YEAR-"`	

	#Get numeric value of month
	case "$MONTH" in
		January) DATENUM+="01";;
		February) DATENUM+="02";;
		March) DATENUM+="03";;
		April) DATENUM+="04";;
		May) DATENUM+="05";;
		June) DATENUM+="06";;
		July) DATENUM+="07";;
		August) DATENUM+="08";;
		September) DATENUM+="09";;
		October) DATENUM+="10";;
		November) DATENUM+="11";;
		December) DATENUM+="12";;

	esac
	
	DATENUM+="-${DAY}"
}

#############
#MAIN METHOD#
#############

#Make date string
if [ $YEAR -gt "1999" ];then
	DATE="${YEAR} ${MONTH} ${DAY}"
else
	DATE="${MONTH} ${DAY} ${YEAR}"
fi

GetUrlFromDate #Set URL

GenerateDateNum

./GrapPicOfDay.sh $URL $DATENUM #Gets Pic and saves it to destination


