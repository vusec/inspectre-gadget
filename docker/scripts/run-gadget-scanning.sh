#!/bin/bash
export WORK_DIR=/work-dir
export RESULTS_FOLDER=/results
set -e

# -----------------------------------------------------------------------------
# 1: Retreive the linux images
# -----------------------------------------------------------------------------

/scripts/get-linux-images.sh

# -----------------------------------------------------------------------------
# 2: Create memory dump of kernel image
# -----------------------------------------------------------------------------

/vm/create-memory-dump.sh

# -----------------------------------------------------------------------------
# 3: Create entry point list
# -----------------------------------------------------------------------------

# /entry-points/generate-indirect-target-list.sh

/entry-points/generate-function-target-list.sh


# -----------------------------------------------------------------------------
# 4: Create reachable list
# -----------------------------------------------------------------------------

if [ ! -f $WORK_DIR/entry-points/vmlinux_asm ] || [ ! -f $WORK_DIR/entry-points/reachable_functions.csv ]; then
    cd $WORK_DIR/entry-points

    START_ADDRESS=`readelf -S $WORK_DIR/images/vmlinux | grep -w ".text" | awk '{print "0x"$5'}`
    END_ADDRESS=`readelf -S $WORK_DIR/images/vmlinux | grep -w ".rodata" | awk '{print "0x"$5'}`
    objdump -D $WORK_DIR/images/dump_vmlinux --start-address=$START_ADDRESS --stop-address=$END_ADDRESS > vmlinux_asm

    echo "name" > reachable_functions.csv

    # Linux 6.10-rc1 (91613e604df0c)
    # https://syzkaller.appspot.com/text?tag=KernelConfig&x=238430243a58f702
    wget https://storage.googleapis.com/syzbot-assets/a088abc3741b/ci-qemu-upstream-1613e604.html -O ci-qemu-upstream-6.10-rc1.html
    /entry-points/get-reached-functions.sh ci-qemu-upstream-6.10-rc1.html > reachable_functions_6.10-rc1.txt

    # Latest finished?
    wget https://storage.googleapis.com/syzkaller/cover/ci-qemu-upstream.html -O ci-qemu-upstream.html
    /entry-points/get-reached-functions.sh ci-qemu-upstream.html > reachable_functions_latest.txt

    cat reachable_functions_6.10-rc1.txt reachable_functions_latest.txt | sort -u >> reachable_functions.csv

else
    echo "[+] [CACHED] Resuing reachable lists from work directory"
fi


# -----------------------------------------------------------------------------
# 5: Start scanner
# -----------------------------------------------------------------------------

OUT_FOLDER=out


cd /results


rm -f fail.txt unsupported.txt
if [ -d $OUT_FOLDER ]; then
    mv $OUT_FOLDER ${OUT_FOLDER}_`date +"%Y%m%d-%H%M"`
fi
mkdir $OUT_FOLDER

echo " [+] Running scanner on call targets"
# Start the analyzer with 20 parallel jobs.
python3 /scanner/run-parallel.py /inspectre/inspectre $WORK_DIR/images/dump_vmlinux $WORK_DIR/entry-points/targets.csv -c /scanner/config_all.yaml -o $OUT_FOLDER -t180 -j32 -s $WORK_DIR/images/vmlinux-dbg
# Move all to output folder
mv fail.txt $OUT_FOLDER
mv unsupported.txt $OUT_FOLDER || true
# Merge all results.
cd $OUT_FOLDER
/analysis/merge_gadgets.sh

# -----------------------------------------------------------------------------
# 6: Analyze results
# -----------------------------------------------------------------------------

cd /results/out
# Run the reasoner
/inspectre/inspectre reason all-gadgets.csv all-gadgets-reasoned.csv | tee log_gadget_scanning.txt
/inspectre/inspectre reason all-tfps.csv all-tfps-reasoned.csv | tee -a log_gadget_scanning.txt


# Copy used entry points
mkdir -p lists
cp /work-dir/entry-points/reachable_functions.csv lists/



# -----------------------------------------------------------------------------
# 7: Summarize
# -----------------------------------------------------------------------------

# Create sqlite3 database
echo "[-] Creating database"
/analysis/build-db.sh

# Execute some queries for manual analysis later
/analysis/get_summary.sh | tee log_merging.txt

cd /results

tar -czvf results_${LINUX_VERSION}_`date +"%Y_%m_%d"`.tar.gz ${OUT_FOLDER}/gadgets.db ${OUT_FOLDER}/asm ${OUT_FOLDER}/lists ${OUT_FOLDER}/log_gadget_scanning.txt ${OUT_FOLDER}/log_merging.txt  > /dev/null


