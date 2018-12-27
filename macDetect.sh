#!/bin/bash

#Declare known Devices
declare -A knownDevices
knownDevices["00:00:00:00:00:00"]="Your Devicename"

#Get Arguments
device=$1

#Oberserve
function observe (){
    sudo tshark -q -l -I -E separator=';' -i $1 -Tfields -e wlan.sa -e wlan.sa_resolved -e radiotap.dbm_antsignal -e wlan.ssid | awk 'BEGIN{FS=";";OFS=";"} { 
            print $1,$2,$3,$4 > "dump/"$1".dump";
            close("dump/"$1".dump");
        }' > /dev/null &
}

#Format Output
function getOutput() {
    output="Devicename|Mac-Address|Mac-Resolved|Signal-Strength|SSID\n"
   
    #Get Longest DeviceName
    longestDeviceName=1
    for K in "${!knownDevices[@]}"; 
    do 
        keyLength=${#K}
        if [ $keyLength -gt $longestDeviceName ]; then
            longestDeviceName=$keyLength
        fi
    done

    for (( c=1; c<=$longestDeviceName; c++ ))
    do
        output+="-"
    done
    output+="\n"
    
    #remove empty files
    rm -f -r dump/.dump > /dev/null

    #get all dump files
    declare -A outputValues
    for file in dump/*.dump; do
        if [ -f $file ]; then
        
        line=$(head -n 1 $file)

        values=(${line//;/ })
        macAddress=${values[0]}
        macAddressResolved=${values[1]}
        signalStrength=${values[2]}
	     ssid=${values[3]}
        deviceName="-"

        #convert signalStrength
        signals=(${signalStrength//,/ })
        signalStrengthClean=${signals[0]}

        #colourize signalstrength
        #SIGNAL STRENGTH: -30 dBm	Amazing | -67 dBm   Very Good | -70 dBm	Okay  | -80 dBm	Not Good | -90 dBm	Unusable
        NC='\033[0m' # No Color
        RED='\033[0;31m'
        ORANGE='\e[0;33m'
        GREEN='\e[0;32m'
        signalColor=""

        if [ "$signalStrengthClean" -ge "-70"  ]; then
                signalColor=$GREEN
        fi

        if [ "$signalStrengthClean" -le "-70"  ]; then
                signalColor=$ORANGE
        fi

        if [ "$signalStrengthClean" -le "-80"  ]; then
                signalColor=$RED
        fi

        
        signalStrengthClean="${signalColor}${signalStrengthClean} dBm${NC}"

        #Replace known Devicename
        for K in "${!knownDevices[@]}"; 
        do 
            if [ "$K" = "$macAddress" ]; then
                deviceName=${knownDevices[$K]}
            fi
        done

        output+="${deviceName}|${macAddress}|${macAddressResolved}|${signalStrengthClean}|${ssid}\n"

        fi
    done

    printf "$output"  | column -c10 -s"|" -t
}

#Clear all Dump-Files
function clearAllDumps (){
    mkdir -p dump && rm -f -r dump/*.*
}

#Clear Dump-Files older than X
function clearOutdatedDumps(){
    find "dump/" -type f -name '*.dump' -mmin +0,15 -exec rm {} \; > /dev/null
}

#Create dump folder and clear any old dumps
clearAllDumps

#Start the Observer
observe $device > /dev/null 

#Clean up the View
sleep 2
clear

echo; while true
do
   output=$(getOutput)
   clear
   echo "$output"
   sleep 2
   clearOutdatedDumps >/dev/null 2>/dev/null
done
