#!/bin/bash

# Domoticz server
DOMOTICZ_SERVER="192.168.X.X:8080"
DOMOTICZ_USER="user"
DOMOTICZ_PWD="password"

# Freebox Server idx
TEMP1_IDX="19"
MEMBUSY_IDX="20"
CPUUSAGE_IDX="23"
UPtime_IDX="24"

# Calculate Temp
cpuTemp0=$(cat /sys/class/thermal/thermal_zone0/temp)
cpuTemp1=$(($cpuTemp0/1000))
cpuTemp2=$(($cpuTemp0/100))
cpuTempM=$(($cpuTemp2 % $cpuTemp1))
Temp1="$cpuTemp1"."$cpuTempM"

# Calculate Mem
MEMTOTAL=`free | grep Mem | awk '{ print $2 }'`
MEMAVA=`free | grep Mem | awk '{ print $7 }'`
MEMBUSY=$((100*(($MEMTOTAL-$MEMAVA))/$MEMTOTAL))
echo "BUSY: "$MEMBUSY"%"

# Calculate CPU usage
PREV_TOTAL=0
PREV_IDLE=0
CPU_USAGE=0
CPU=(`cat /proc/stat | grep '^cpu '`) # Get the total CPU statistics.
  unset CPU[0]                          # Discard the "cpu" prefix.
  IDLE=${CPU[4]}                        # Get the idle CPU time.
  TOTAL=0
  for VALUE in "${CPU[@]}"; do
    let "TOTAL=$TOTAL+$VALUE"
  done
  let "DIFF_IDLE=$IDLE-$PREV_IDLE"
  let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
  let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"
  CPU_USAGE="$DIFF_USAGE"
  PREV_TOTAL="$TOTAL"
  PREV_IDLE="$IDLE"
  echo "$CPU_USAGE"

  # Calculate uptime
UPhour=`uptime -p | awk '{ print $2 }'`
UPmin=`uptime -p | awk '{ print $4 }'`
UPtime1="$(((($UPhour*60))+(($UPmin))))"
UPtime=("$UPtime1")
UPtime+="%20Minutes"
echo $UPtime

#Send Value
curl -S "http://$DOMOTICZ_USER:$DOMOTICZ_PWD@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$TEMP1_IDX&nvalue=0&svalue=$Temp1"
curl -S "http://$DOMOTICZ_USER:$DOMOTICZ_PWD@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$MEMBUSY_IDX&nvalue=0&svalue=$MEMBUSY"
curl -S "http://$DOMOTICZ_USER:$DOMOTICZ_PWD@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$CPUUSAGE_IDX&nvalue=0&svalue=$CPU_USAGE"
curl -S "http://$DOMOTICZ_USER:$DOMOTICZ_PWD@$DOMOTICZ_SERVER/json.htm?type=command&param=udevice&idx=$UPtime_IDX&nvalue=0&svalue=$UPtime"










