#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
   echo "Please run as root"
   exit 1
fi

make -B

echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

rm -f -r results
mkdir results

for i in $(seq 500)
do
    echo "-- Iteration $i --"
    for option in $(seq 0 4)
    do
	./main ibt -c $option | tee -a results/results_${1}_ibt_c${option}.txt
        ./main fine_ibt -c $option | tee -a results/results_${1}_fineibt_c${option}.txt
    done
done
