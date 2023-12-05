ANALYZER_FOLDER=analyzer
CONFIG=config_all.yaml

OUT_FOLDER=out
GADGET_FOLDER=$OUT_FOLDER/gadgets
TFP_FOLDER=$OUT_FOLDER/tfps
LOG_FOLDER=$OUT_FOLDER/logs
ASM_FOLDER=$OUT_FOLDER/asm

if [ "$#" -ne 3 ]; then
    echo "USAGE: $0 <BINARY> <GADGET_CSV> <JOBS>"
fi

BINARY=$1
GADGET_LIST=$2
JOBS=$3

run-analyzer () {
    echo "Spawned analyzer"
    for l in $(cat "$1"); do
        addr=$(echo $l | sed 's/,/ /g' | awk '{ print $1 }')
        name=$(echo $l | sed 's/,/ /g' | awk '{ print $2 }')
        echo "addr: $addr    name: $name " >> $OUT_FOLDER/finished.txt
        timeout 360 python3 $ANALYZER_FOLDER/main.py $BINARY --config $CONFIG --gadget-address $addr --cache-project --csv $GADGET_FOLDER/$name-$addr.csv --tfp-csv $TFP_FOLDER/$name-$addr.csv --asm $ASM_FOLDER 2> $LOG_FOLDER/out_$name-$addr.log 2>&1
        echo "Exited with code $?" >> $LOG_FOLDER/out_$name-$addr.log
    done
}

# Prepare output folder.
mv $OUT_FOLDER $OUT_FOLDER.backup
mkdir $OUT_FOLDER
mkdir GADGET_FOLDER TFP_FOLDER LOG_FOLDER $OUT_FOLDER/asm

# Split the gadget list to run the analyzer in parallel.
rm splitted*
n_gadgets=$(cat $GADGET_LIST | wc -l)
gadgets_per_task=$(python -c "from math import ceil; print ceil($n_gadgets/$JOBS)")
split -l $gadgets_per_task --numeric-suffixes $GADGET_LIST 'splitted'

# Run analyzer.
 for f in ./splitted*; do
     run-analyzer "$f" &
 done
