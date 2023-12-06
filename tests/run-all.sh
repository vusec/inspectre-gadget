make clean
make

mv gadgets.csv gadgets_backup.csv
touch gadgets.csv

mv tfp.csv tfp_backup.csv
touch tfp.csv

mv asm asm_backup
mkdir asm

for f in $(ls ./*/gadget)
do
    echo "\n================= $f ================\n"
    cat $f.s | batcat -l asm
    echo ""
    objdump --adjust-vma=0x4000000 -d -Mintel $f | batcat -l asm
    echo ""
    python3 ../analyzer/main.py --config config_all.yaml $f --csv gadgets.csv --tfp-csv tfp.csv --asm asm || exit -1
#    read
done
