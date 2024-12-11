if [ "$#" -ne 1 ]; then
    echo "USAGE: $0 <test_case_name>"
    exit 1
fi


 f=$1/gadget
    echo "\n================= $f ================\n"
    name=`echo $1 | sed 's/\/*$//g'`
    cat $f.s | batcat -l asm
    echo "\n"
    objdump --adjust-vma=0x4000000 -d -Mintel $f | batcat -l asm
    echo ""
    python3 ../../inspectre analyze --config config_all.yaml --base-address 0x4000000 --address 0x4000000 --name $name --output output/gadgets.csv --tfp-output output/tfp.csv --asm output/asm $f
