#!/bin/bash

if [ "$#" != "2" ]; then
	echo "A Breached Domain Parser based on Heath Adams\'s research"
	echo "\nUsage: breach-parse <domain to search> <file output>"
	echo "Example: parser.sh @gmail.com gmail.txt"
	echo "For Multiple domains: parser.sh \"@gmail.com|@yahoo.com\" domains.txt"
	exit 1

else
	fullFile=$2
	fbname=$(basename "$fullFile" | cut -d. -f1)
	master=$fbname-master.txt
	users=$fbname-user.txt
	passwords=$fbname-passwords.txt

	touch $master
	totFiles=$(find /opt/breach-parse/BreachCompilation/data -type f | wc -l)
	fileCount=0

	function progressBar {
		let_progress=(${fileCount}*100/${totFiles}*100)/100
		let_done=(${_progress}*4)/10
		let_left=40-$_done

		_fill=$(printf "%${_done}s")
		_empty=$(printf "%${_left}s")
	printf "\rProgress : [${_fill// /\#}${_empty// /-}] ${_progress}%%"
	}

	find /opt/breach-parse/BreachCompilation/data -type f -print0 | while read -d $'\0' file

	do
		grep -a -E "$1" "$file" >> $master
		((++fileCount))
		progressBar ${number} ${totFiles}
	done
fi
sleep 3
awk -F':' '{print $1}' $master > $users
sleep 1
awk -F':' '{print $2}' $master > $passwords
echo
exit 0
