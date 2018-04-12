#!/bin/bash
#
# Test subnet connectivity after fiber cable to island has been cut
#
DEBUG=
btracer="false"
bpinger="true"
VERSION="1.6"
user=$(whoami)

scriptname="`basename $0`"
# Set max-hop count here
TRACEROUTE="traceroute -m 8"

# Format of ip address list file
# name ip_address ie. Name www.xxx.yyy.zzz
connect_list_dir="/home/$user/bin"
connect_list_fname="connect_list.txt"
connect_list_file="$connect_list_dir/$connect_list_fname"

# Log file name
log_dir="/home/$user/pinglogs"
log_fname="pinglog.txt"
log_file="$log_dir/$log_fname"

declare -a name_array
declare -a ip_array

function dbgecho { if [ ! -z "$DEBUG" ] ; then echo "$*"; fi }

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

# ===== function ctrl_c handler
function ctrl_c() {
        echo "** detected CTRL-C ... exiting"
	exit
}
# ===== function log
function log () {
    if [ -z "$1" ]; then
        tee -a "$log_file"
    else
       printf "$@\n" | tee -a $log_file
    fi
}

# ===== function usage
function usage() {
   echo "Usage: $scriptname [-d][-a][-t][-p][-h]" >&2
   echo "   -d set DEBUG to true"
   echo "   -a Use all addresses, some fail"
   echo "   -t set traceroute to true"
   echo "   -p set ping to true, default"
   echo "   -h Display this message"
   echo
}

# ===== main

if [ ! -d $log_dir ] ; then
   mkdir -p $log_dir
   if [ "$?" -ne 0 ] ; then
      echo "Failure making directory $log_dir, file with same name exists" | log
      exit 1
   fi
fi

printf "\n==== Ping test version: %s %s ====\n" $VERSION "$(date)" | log

if [ ! -f $connect_list_file ] ; then
   echo "IP connect list file: $connect_list_file NOT Found ... exiting" | log
   exit 1
fi

lineno=0
while IFS='' read -r line || [[ -n "$line" ]] ; do
   name=$(echo $line | cut -d ' ' -f1)
   ipaddr=$(echo $line | cut -d ' ' -f2)
   if [ ! -z "$ipaddr" ] ; then
#      echo "Line $lineno: $line, Name: $name, ip: $ipaddr"
      name_array[lineno]="$name"
      ip_array[lineno]="$ipaddr"
#      echo "Array $lineno: Name: ${name_array[lineo]}, ip: ${ip_array[lineno]}"
      lineno=$(( lineno + 1 ))
   fi
done < $connect_list_file

ipcnt=${#ip_array[@]}
ipcnt=$(( ipcnt - 3 ))

echo " Found in file total addresses: $lineno, but only using: $ipcnt" | log

#echo "name: ${name_array[*]}"
#echo "ipad: ${ip_array[*]}"

# Any command line args?
if [[ $# -gt 0 ]] ; then
   while [[ $# -gt 0 ]] ; do
   key="$1"

   case $key in
      -d|--debug)
         DEBUG=1
      ;;

      -a|--all)
         ipcnt=${#ip_array[@]}
      ;;

      -t|--trace)
         btracer="true"
      ;;

      -p|--ping)
         bpinger="true"
      ;;
      -h|help)
         usage
         exit 0
      ;;

      *)
         # unknown option
         echo "Unknow option: $key" | log
         usage
         exit 1
      ;;
   esac
   shift # past argument or value
   done

   dbgecho "Found command line arg, DEBUG: $DEBUG, ip cnt: $ipcnt, trace route: $btracer, ping: $bpinger"
fi

dbgecho "Name array: ${name_array[@]}"
dbgecho "IP array: ${ip_array[@]}"
dbgecho "Using $SHELL, version: $BASH_VERSION"

# Reference for getting avg round trip time
# ping -c 4 www.stackoverflow.com | tail -1| awk '{print $4}' | cut -d '/' -f 2

for (( i=0; i<ipcnt; i++)) ; do

   ping -c 1 ${ip_array[$i]} > /dev/null 2>&1
   ping_ret="$?"

   if [ "$ping_ret" = "0" ] ; then
      ping_result=$(ping -c 1 ${ip_array[$i]}| tail -1 | awk '{print $4}' | cut -d '/' -f 2)
      printf " %2d: %-6s %-15s success rtt: %s\n" $i ${name_array[$i]}  ${ip_array[$i]}  ${ping_result} | log
   else
      printf " %2d: %-6s %-15s failed: %s\n" $i ${name_array[$i]}  ${ip_array[$i]} $ping_ret | log
   fi
done

if [ "$btracer" = "true" ] ; then
   printf "\n" | log
   for (( i=0; i<ipcnt; i++)) ; do
      echo "---- $i: ${name_array[$i]} traceroute: ${ip_array[$i]}" | log
      $TRACEROUTE ${ip_array[$i]} | log
   done
fi

exit 0
