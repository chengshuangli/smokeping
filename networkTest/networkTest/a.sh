 #!/bin/bash
 cat ips_d.csv  | sort -t "," -k 2 -k 1  | awk -F, '{OFS="-"} {print $2,$3,$4","$5}' >> monitorIP.csv
