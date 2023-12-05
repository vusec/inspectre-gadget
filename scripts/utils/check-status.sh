awk -v var1=$(cat finished.txt | wc -l) -v var2=$(cat $1 | wc -l) 'BEGIN { print ( var1 / var2 )* 100 }'
