make clean
make

rm gadgets.csv
rm tfp.csv
rm -rf asm && mkdir asm

for f in $(ls ./*/gadget)
do
    echo "\n================= $f ================\n"
    cat $f.s | batcat -l asm
    echo ""
    objdump --adjust-vma=0x4000000 -d -Mintel $f | batcat -l asm
    echo ""
    python3 ../inspectre analyze $f --config config_all.yaml --address 0x4000000 --output gadgets.csv --tfp-output tfp.csv --asm asm || exit -1
#    read
done
