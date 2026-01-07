#!/bin/bash
set -e

GADGET_FOLDER='gadgets'
TFP_FOLDER='tfps'

first_file=`ls $GADGET_FOLDER/ | head -n1`
head -n 1 $GADGET_FOLDER/$first_file > all-gadgets.csv
printf '%s\0' $GADGET_FOLDER/*.csv | xargs -0 tail -qn +2 >> all-gadgets.csv


first_file=`ls $TFP_FOLDER/ | head -n1`
head -n 1 $TFP_FOLDER/$first_file > all-tfps.csv
printf '%s\0' $TFP_FOLDER/*.csv | xargs -0 tail -qn +2 >> all-tfps.csv
