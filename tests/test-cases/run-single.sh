if [ "$#" -ne 1 ]; then
    echo "USAGE: $0 <test_case_name>"
    exit 1
fi


f=$1/gadget
name=`basename $1`

# Select default or test-case specific config
if [ -f $1/config.yaml ]; then cfg=$1/config.yaml; else cfg=config_all.yaml; fi

echo "================= $f ================"
cat $f.s | batcat -l asm
echo "\n"
objdump --adjust-vma=0x4000000 -d -Mintel $f | batcat -l asm
echo ""
python3 ../../inspectre analyze --config $cfg --base-address 0x4000000 --address 0x4000000 --name $name --output output/gadgets.csv --tfp-output output/tfp.csv --half-gadget-output output/half.csv --asm output/asm $f
