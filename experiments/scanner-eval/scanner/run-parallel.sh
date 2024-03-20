ANALYZER_FOLDER=/inspectre
CONFIG=config_all.yaml

OUT_FOLDER=out
GADGET_FOLDER=$OUT_FOLDER/gadgets
TFP_FOLDER=$OUT_FOLDER/tfps
LOG_FOLDER=$OUT_FOLDER/logs
ASM_FOLDER=$OUT_FOLDER/asm

if [ "$#" -ne 3 ]; then
    echo "USAGE: $0 <BINARY> <GADGET_CSV> <JOBS>"
    exit 1
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
        timeout 360 python3 $ANALYZER_FOLDER/inspectre analyze $BINARY --config $CONFIG --address $addr --name $name --cache-project --output $GADGET_FOLDER/$name-$addr.csv --tfp-output $TFP_FOLDER/$name-$addr.csv --asm $ASM_FOLDER 2> $LOG_FOLDER/out_$name-$addr.log
        echo "Exited with code $?" >> $LOG_FOLDER/out_$name-$addr.log
    done
}

# Prepare output folder.
rm -f $OUT_FOLDER.backup
mv $OUT_FOLDER $OUT_FOLDER.backup
mkdir $OUT_FOLDER
mkdir $GADGET_FOLDER $TFP_FOLDER $LOG_FOLDER $OUT_FOLDER/asm
touch fail.txt

# Split the gadget list to run the analyzer in parallel.
rm -f $OUT_FOLDER/splitted*
n_gadgets=$(cat $GADGET_LIST | wc -l)
gadgets_per_task=$(python3 -c "from math import ceil; print(ceil($n_gadgets/$JOBS))")

echo $gadgets_per_task
split -l $gadgets_per_task --numeric-suffixes $GADGET_LIST "$OUT_FOLDER/splitted"

# Run analyzer.
 for f in $OUT_FOLDER/splitted*; do
     run-analyzer "$f" &
     pids[${i}]=$!
 done

# wait for all pids
for pid in ${pids[*]}; do
    wait $pid
done
