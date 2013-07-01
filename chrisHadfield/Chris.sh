#!/bin/bash


for NUM in {1..30}; do
	URL="http://weather.aol.com/2013/05/13/chris-hadfields-30-best-photos-from-space/${NUM}"
	echo "[+]Getting twitter page URL. Using URL=${URL}"
	PICURL=`curl -s $URL | egrep -o "pic.twitter.com/.{10}" | tail -1`
	echo "[+]Getting URL to jpg. Using PICURL=${PICURL}"
	PIC=`curl -s -L ${PICURL} | egrep -o "http?s://pbs.twimg.com/media/.{15}.jpg:large" | tail -1`
	echo "[+]Downloading image. Using PIC=${PIC}"
	FN="ChrisHadfield-${NUM}-bestFromSpace.jpg"
	curl -s ${PIC} -o $FN
	if [ $? -eq 0 ]; then
		echo "$FN saved"
	else
		echo "ERROR, $NUM failed"
	fi
done;
