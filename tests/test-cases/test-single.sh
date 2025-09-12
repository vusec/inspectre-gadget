OUT_REF_FOLDER="ref-output"
ASM_REF_FOLDER="ref-asm"
OUT_FOLDER="output"
ASM_FOLDER="asm"

do_update=0

# ------------------------------------------------------------------------------
# Input checks

if [[ "$#" -ne 1 && "$#" -ne 2 ]]; then
    echo "USAGE: $0 <test_case_name> --update"
    exit 1
fi

if [ "$#" -eq 2 ]; then
    if [ "$2" != "--update" ]; then
        echo "USAGE: $0 <test_case_name> --update"
        exit 1
    fi
    do_update=1
fi

# ------------------------------------------------------------------------------
# Cleanup folder

f=$1/gadget
name=`basename $1`

# Select default or test-case specific config
if [ -f $1/config.yaml ]; then cfg=config.yaml; else cfg=../config_all.yaml; fi

echo "    testing: ${name}"

cd $1
rm -f -r ${OUT_FOLDER}
rm -f -r ${ASM_FOLDER}
mkdir -p ${OUT_FOLDER}
rm -f gadgets.csv
rm -f tfp.csv
rm -f half.csv

# ------------------------------------------------------------------------------
# Run InSpectre Scanner

objdump --adjust-vma=0x4000000 -d -Mintel gadget > ${OUT_FOLDER}/out.txt

echo ""  >> ${OUT_FOLDER}/out.txt
echo "== SCANNER ==" >> ${OUT_FOLDER}/out.txt
python3 ../../../inspectre analyze --config $cfg --base-address 0x4000000 --address 0x4000000 --name $name --output gadgets.csv --tfp-output tfp.csv --asm asm --half-gadget-output half.csv gadget 2> /dev/null >> ${OUT_FOLDER}/out.txt || true
[ -f fail.txt ] && mv fail.txt ${OUT_FOLDER}/fail.txt

# ------------------------------------------------------------------------------
# Run InSpectre Reasoner

if [ -f gadgets.csv ]; then
    echo ""  >> ${OUT_FOLDER}/out.txt
    echo "== REASONER TRANSMISSION ==" >> ${OUT_FOLDER}/out.txt
    python3 ../../../inspectre reason gadgets.csv gadgets-reasoned.csv &>> ${OUT_FOLDER}/out.txt
fi

if [ -f tfp.csv ]; then
    echo ""  >> ${OUT_FOLDER}/out.txt
    echo "== REASONER DISPATCH ==" >> ${OUT_FOLDER}/out.txt
    python3 ../../../inspectre reason tfp.csv tfp-reasoned.csv &>> ${OUT_FOLDER}/out.txt
fi


# ------------------------------------------------------------------------------
# Execute queries for disclosure gadgets

if [ -f gadgets.csv ]; then
    echo "== GADGETS =="  >> ${OUT_FOLDER}/scanner_data.txt
    for sql in in ../../test-queries/scanner-gadgets/*.sql;
    do
        [ -e "$sql" ] || continue
        echo $sql >> ${OUT_FOLDER}/scanner_data.txt
        sqlite3 :memory: -cmd '.mode csv' -cmd '.separator ;' -cmd ".import gadgets.csv gadgets" -cmd '.mode table -wrap 0 --wordwrap on' < $sql >> ${OUT_FOLDER}/scanner_data.txt || true
        echo "" >> ${OUT_FOLDER}/scanner_data.txt
    done
fi

if [ -f gadgets-reasoned.csv ]; then
    # First reasoner specific fields
    for sql in in ../../test-queries/reasoner-gadgets/*.sql;
    do
        [ -e "$sql" ] || continue
        echo $sql >> ${OUT_FOLDER}/reasoner_data.txt
        sqlite3 :memory: -cmd '.mode csv' -cmd '.separator ;' -cmd ".import gadgets-reasoned.csv gadgets" -cmd '.mode table -wrap 0 --wordwrap on' < $sql >> ${OUT_FOLDER}/reasoner_data.txt || true
        echo "" >> ${OUT_FOLDER}/reasoner_data.txt
    done

     # Next again the scanner fields, in case we screwed something up in the reasoner
    for sql in in ../../test-queries/scanner-gadgets/*.sql;
    do
        [ -e "$sql" ] || continue
        echo $sql >> ${OUT_FOLDER}/reasoner_data.txt
        sqlite3 :memory: -cmd '.mode csv' -cmd '.separator ;' -cmd ".import gadgets-reasoned.csv gadgets" -cmd '.mode table -wrap 0 --wordwrap on' < $sql >> ${OUT_FOLDER}/reasoner_data.txt || true
        echo "" >> ${OUT_FOLDER}/reasoner_data.txt
    done
fi

# ------------------------------------------------------------------------------
# Execute queries for dispatch (TFP) gadgets

if [ -f tfp.csv ]; then
    echo "== TFPs =="  >> ${OUT_FOLDER}/scanner_data.txt
    for sql in in ../../test-queries/scanner-tfp/*.sql;
    do
        [ -e "$sql" ] || continue
        echo $sql >> ${OUT_FOLDER}/scanner_data.txt
        sqlite3 :memory: -cmd '.mode csv' -cmd '.separator ;' -cmd ".import tfp.csv tfps" -cmd '.mode table -wrap 0 --wordwrap on' < $sql >> ${OUT_FOLDER}/scanner_data.txt || true
        echo "" >> ${OUT_FOLDER}/scanner_data.txt
    done
fi

if [ -f tfp-reasoned.csv ]; then
    # First reasoner specific fields
    for sql in in ../../test-queries/reasoner-tfp/*.sql;
    do
        [ -e "$sql" ] || continue
        echo $sql >> ${OUT_FOLDER}/reasoner_data.txt
        sqlite3 :memory: -cmd '.mode csv' -cmd '.separator ;' -cmd ".import tfp-reasoned.csv tfps" -cmd '.mode table -wrap 0 --wordwrap on' < $sql >> ${OUT_FOLDER}/reasoner_data.txt || true
        echo "" >> ${OUT_FOLDER}/reasoner_data.txt
    done

     # Next again the scanner fields, in case we screwed something up in the reasoner
    for sql in in ../../test-queries/scanner-tfp/*.sql;
    do
        [ -e "$sql" ] || continue
        echo $sql >> ${OUT_FOLDER}/reasoner_data.txt
        sqlite3 :memory: -cmd '.mode csv' -cmd '.separator ;' -cmd ".import tfp-reasoned.csv tfps" -cmd '.mode table -wrap 0 --wordwrap on' < $sql >> ${OUT_FOLDER}/reasoner_data.txt || true
        echo "" >> ${OUT_FOLDER}/reasoner_data.txt
    done
fi

# ------------------------------------------------------------------------------
# Execute queries for Half-Spectre gadgets

if [ -f half.csv ]; then
    echo "== Half-Spectre =="  >> ${OUT_FOLDER}/scanner_data.txt
    for sql in in ../../test-queries/scanner-half-spectre/*.sql;
    do
        [ -e "$sql" ] || continue
        echo $sql >> ${OUT_FOLDER}/scanner_data.txt
        sqlite3 :memory: -cmd '.mode csv' -cmd '.separator ;' -cmd ".import half.csv halfgadgets" -cmd '.mode table -wrap 0 --wordwrap on' < $sql >> ${OUT_FOLDER}/scanner_data.txt || true
        echo "" >> ${OUT_FOLDER}/scanner_data.txt
    done
fi


# ------------------------------------------------------------------------------
# Create ref folder if it does not exist

if [ ! -d ${OUT_REF_FOLDER} ]; then
    echo "[+] ref folder does not exist, creating it and skipping ${name}"
    rm -f ${OUT_REF_FOLDER}
    mv ${OUT_FOLDER} ${OUT_REF_FOLDER}
    rm -f -r ${ASM_REF_FOLDER}
    [ -d ${ASM_FOLDER} ] && mv ${ASM_FOLDER} ${ASM_REF_FOLDER}

    # We exit since we cannot compare
    exit 0
fi

# ------------------------------------------------------------------------------
# Perform diff

git --no-pager diff --minimal --no-index --word-diff=color --word-diff-regex=. ${OUT_REF_FOLDER} ${OUT_FOLDER};

if [ $? -ne 0 ];
then
    # Folders differ
    echo -e "\e[31m[-] failed:   ${name}\e[0m"

    if [ $do_update -eq 1 ]; then
        echo "    Updating ref folders:  ${name}"
        rm -f -r ${OUT_REF_FOLDER}
        rm -f -r ${ASM_REF_FOLDER}
        mv ${OUT_FOLDER} ${OUT_REF_FOLDER}
        [ -d ${ASM_FOLDER} ] && mv ${ASM_FOLDER} ${ASM_REF_FOLDER}
    fi

    exit 1

else
    # Folders are equal
    echo "[+] passed:  ${name}"
    exit 0
fi
