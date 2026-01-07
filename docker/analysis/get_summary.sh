OWN_DIR=`dirname "$0"`

# --
echo "==========================================================="
echo "General Stats"

sqlite3 gadgets.db --cmd  ".mode table" < ${OWN_DIR}/queries/general_stats.sql

# --
echo "==========================================================="
echo "Exploitable Stats"

sqlite3 gadgets.db --cmd  ".mode table" < ${OWN_DIR}/queries/exploitable_stats.sql

# --
echo "==========================================================="
echo "Exploitable Transmission Gadgets"

sqlite3 gadgets.db --cmd  ".mode table" < ${OWN_DIR}/queries/exploitable_trans.sql

# --
echo "==========================================================="
echo "Exploitable Secret Dependent Branch"

sqlite3 gadgets.db --cmd  ".mode table" < ${OWN_DIR}/queries/exploitable_sdb.sql

# --
echo "==========================================================="
echo "Exploitable TFPs"

sqlite3 gadgets.db --cmd  ".mode table" < ${OWN_DIR}/queries/exploitable_tfp.sql

# --
echo "==========================================================="
echo "Exploitable SLAM"

sqlite3 gadgets.db --cmd  ".mode table" < ${OWN_DIR}/queries/exploitable_slam.sql
