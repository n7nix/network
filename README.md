# Network testing scripts

### connect_test.sh

Used to test network connectivity within a county after main fiber
optic cable is cut.

The script will create a directory in /home/`<user>`/pinglogs and will
log to file /home/`<user>`/pinglogs/pinglog.txt

Since crontab wants explicit paths the following is an example where I copied
connect_test.sh connect_list.txt to my local bin /home/`<user>`/bin

Crontab entry for running every 15 minutes looks like this:
```
*/15 *   *   *   *  /home/gunn/`<user>`/connect_test.sh -t > /dev/null 2>&1
```

##### Files

* local bin
  * connect_test.sh
  * connect_list.txt

* log file
  * /home/`<user>`/pinglogs/pinglog.txt

* Format of ip address list file connect_list.txt
  * name ip_address
```
Bob  10.1.2.3
```

##### Command line options

* Usage: $scriptname [-d][-a][-t][-p][-h]
```
   -d set DEBUG to true
   -a Use all addresses, some fail
   -t set traceroute to true
   -p set ping to true, default
   -h Display this message
```
