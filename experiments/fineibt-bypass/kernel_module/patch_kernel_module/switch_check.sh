

sudo dmesg -c && echo $1 > /proc/patch_kernel/switch_fine_ibt_check || true && dmesg && sudo dmesg -C
