#!/bin/bash
#207.254.177.165  "kill -9 `ps -ef  | grep FPing | grep -v 'grep' | awk  '{print \$2}'`"
kill -9 `ps -ef  | egrep 'smokeping.dis|smokeping.cgi' | grep -v 'grep' | awk  '{print $2}'`
/usr/local/smokeping/bin/smokeping.dist start >/dev/null && echo smokeping retart ok
/etc/init.d/httpd restart >/dev/null && echo apache restart ok
