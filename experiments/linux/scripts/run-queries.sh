echo "[-] Creating database"
sqlite3 < queries/join_all.sqlite3
echo "[-] Get general stats"
sqlite3 gadgets.db -cmd '.mode table' < queries/general_stats.sql
echo "[-] Get stats for exploitable gadgets"
sqlite3 gadgets.db -cmd '.mode table' < queries/exploitable_stats.sql
echo "[-] Get stats for non-exploitable gadgets"
sqlite3 gadgets.db -cmd '.mode table' < queries/non_exploitable_stats.sql
