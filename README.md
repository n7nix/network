# Network testing scripts

### connect_test.sh

Used to test network connectivity within a county after main fiber
optic cable is cut.

The script will create a directory in _/home/`<user>`/pinglogs_ and will
log to file _/home/`<user>`/pinglogs/pinglog.txt_

Since crontab wants explicit paths the following is an example where I copied
_connect_test.sh_ and _connect_list.txt_ to my local bin /home/`<user>`/bin

Crontab entry for running every 15 minutes looks like this:
```
*/15 *   *   *   *  /home/`<user>`/bin/connect_test.sh -t > /dev/null 2>&1
```

##### Files

* local bin
  * _connect_test.sh_
  * _connect_list.txt_

* log file
  * _/home/`<user>`/pinglogs/pinglog.txt_

* Format of ip address list file _connect_list.txt_
  * name ip_address
```
Bob  10.1.2.3
```

##### Command line options

* Usage: connect_test.sh [-d][-a][-t][-p][-h]
```
   -d set DEBUG to true
   -a Use all addresses, some fail
   -t set traceroute to true
   -p set ping to true, default
   -h Display this message
```
