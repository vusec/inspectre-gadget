 f=$1/gadget
    echo "\n================= $f ================\n"
    cat $f.s | batcat -l asm
    echo "\n"
    objdump --adjust-vma=0x4000000 -d -Mintel $f | batcat -l asm
    echo ""
    python3 ../../inspectre analyze --config config_all.yaml --address 0x4000000 $f
