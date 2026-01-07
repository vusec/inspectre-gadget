grep Exited $1/* | awk 'NF>1{print "Exited with code " $NF}' | sort | uniq -c
