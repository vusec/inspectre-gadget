echo "[-] Creating database"
sqlite3 < queries/join_all.sqlite3
echo "[-] Get stats for exploitable gadgets"
sqlite3 gadgets.db -cmd '.mode table' < queries/exploitable_and_reachable_stats.sql
echo "[-] Get stats for non-exploitable gadgets"
sqlite3 gadgets.db -cmd '.mode table' < queries/non_exploitable_stats.sql
