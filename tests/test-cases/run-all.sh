make clean
make

rm -rf output && mkdir output

for f in $(ls ./*/gadget)
do
    echo "\n================= $f ================\n"
    name=`echo $f | awk -F/ '{ print $2 }'`
    cat $f.s | batcat -l asm
    echo ""
    objdump --adjust-vma=0x4000000 -d -Mintel $f | batcat -l asm
    echo ""
    python3 ../../inspectre analyze $f --config config_all.yaml --base-address 0x4000000 --address 0x4000000 --name $name --output output/gadgets.csv --tfp-output output/tfp.csv --asm output/asm || exit -1
done
