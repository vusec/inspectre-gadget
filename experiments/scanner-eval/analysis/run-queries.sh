echo "" > stats.txt

echo "[-] Get general stats"
sqlite3 gadgets.db -cmd '.mode table' < /analysis/queries/general_stats.sql >> stats.txt
echo "[-] Get stats for exploitable gadgets"
sqlite3 gadgets.db -cmd '.mode table' < /analysis/queries/exploitable_stats.sql >> stats.txt
echo "[-] Get stats for non-exploitable gadgets"
sqlite3 gadgets.db -cmd '.mode table' < /analysis/queries/non_exploitable_stats.sql >> stats.txt
echo "[-] Get stats for fineibt gadgets"
sqlite3 gadgets.db -cmd '.mode table' < /analysis/queries/fineibt_gadgets.sql >> stats.txt
echo "[-] Get stats for tfps"
sqlite3 gadgets.db -cmd '.mode table' < /analysis/queries/exploitable_tfps.sql >> stats.txt
echo "[-] Get stats for exploitable slam gadgets"
sqlite3 gadgets.db -cmd '.mode table' < /analysis/queries/exploitable_slam.sql >> stats.txt
