.mode csv
.separator ;

-- Import analysis results
.import all-gadgets-reasoned.csv gadgets
.import all-tfps-reasoned.csv tfps

-- Import lists generated from the target
.import lists/reachable_functions.csv reachable_functions

.save gadgets.db
