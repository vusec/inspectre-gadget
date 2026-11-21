#!/bin/bash

OUT_REF_FOLDER="ref-output"
ASM_REF_FOLDER="ref-asm"
OUT_FOLDER="output"
ASM_FOLDER="asm"

E2E_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASES_DIR="$E2E_DIR/cases"
QUERIES_DIR="$E2E_DIR/queries"
DEFAULT_CFG="$E2E_DIR/config_all.yaml"

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

name="$1"
case_dir="$CASES_DIR/$name"
[ -d "$case_dir" ] || { echo "unknown test case: $name"; exit 1; }

# Select default or test-case specific config
if [ -f "$case_dir/config.yaml" ]; then cfg="$case_dir/config.yaml"; else cfg="$DEFAULT_CFG"; fi

echo "    testing: ${name}"

cd "$case_dir" || exit 1
rm -f -r "$OUT_FOLDER"
rm -f -r "$ASM_FOLDER"
mkdir -p "$OUT_FOLDER"
rm -f gadgets.csv
rm -f tfp.csv
rm -f half.csv

# ------------------------------------------------------------------------------
# Run InSpectre Scanner

objdump --adjust-vma=0x4000000 -d -Mintel gadget > "$OUT_FOLDER/out.txt"

echo ""  >> "$OUT_FOLDER/out.txt"
echo "== SCANNER ==" >> "$OUT_FOLDER/out.txt"
python3 -m inspectre_gadget analyze --config "$cfg" --base-address 0x4000000 --address 0x4000000 --name "$name" --output gadgets.csv --tfp-output tfp.csv --asm "$ASM_FOLDER" --half-gadget-output half.csv gadget 2> /dev/null >> "$OUT_FOLDER/out.txt" || true
[ -f fail.txt ] && mv fail.txt "$OUT_FOLDER/fail.txt"

# ------------------------------------------------------------------------------
# Run InSpectre Reasoner

if [ -f gadgets.csv ]; then
    echo ""  >> "$OUT_FOLDER/out.txt"
    echo "== REASONER TRANSMISSION ==" >> "$OUT_FOLDER/out.txt"
    python3 -m inspectre_gadget reason --config "$cfg" gadgets.csv gadgets-reasoned.csv &>> "$OUT_FOLDER/out.txt"
fi

if [ -f tfp.csv ]; then
    echo ""  >> "$OUT_FOLDER/out.txt"
    echo "== REASONER DISPATCH ==" >> "$OUT_FOLDER/out.txt"
    python3 -m inspectre_gadget reason --config "$cfg" tfp.csv tfp-reasoned.csv &>> "$OUT_FOLDER/out.txt"
fi
# Drop environment-specific angr log lines (e.g., unicorn version mismatch),
# format: "ERROR    | 2024-01-01 12:00:00,000 | angr.some.module | message"
sed -i -E '/^(DEBUG|INFO|WARNING|ERROR|CRITICAL) +\| [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9:,]+ \| /d' "$OUT_FOLDER/out.txt"

# ------------------------------------------------------------------------------
# Queries

# run_queries <csv> <table> <query-subdir> <outfile>
# Runs every $QUERIES_DIR/<query-subdir>/*.sql on <csv> (imported as <table>).
# Each result is preceded by the query's name relative to $QUERIES_DIR, so the
# output does not depend on where the queries folder lives.
run_queries() {
    local csv=$1 table=$2 subdir=$3 out=$4
    for sql in "$QUERIES_DIR/$subdir"/*.sql; do
        [ -e "$sql" ] || continue
        echo "$subdir/$(basename "$sql")" >> "$out"
        sqlite3 :memory: -cmd '.mode csv' -cmd '.separator ;' -cmd ".import $csv $table" -cmd '.mode table -wrap 0 --wordwrap on' < "$sql" >> "$out" || true
        echo "" >> "$out"
    done
}

SCANNER_DATA="$OUT_FOLDER/scanner_data.txt"
REASONER_DATA="$OUT_FOLDER/reasoner_data.txt"

# Disclosure gadgets
if [ -f gadgets.csv ]; then
    echo "== GADGETS ==" >> "$SCANNER_DATA"
    run_queries gadgets.csv gadgets scanner-gadgets "$SCANNER_DATA"
fi

if [ -f gadgets-reasoned.csv ]; then
    # First reasoner specific fields, then again the scanner fields,
    # in case we screwed something up in the reasoner.
    run_queries gadgets-reasoned.csv gadgets reasoner-gadgets "$REASONER_DATA"
    run_queries gadgets-reasoned.csv gadgets scanner-gadgets "$REASONER_DATA"
fi

# Dispatch (TFP) gadgets
if [ -f tfp.csv ]; then
    echo "== TFPs ==" >> "$SCANNER_DATA"
    run_queries tfp.csv tfps scanner-tfp "$SCANNER_DATA"
fi

if [ -f tfp-reasoned.csv ]; then
    run_queries tfp-reasoned.csv tfps reasoner-tfp "$REASONER_DATA"
    run_queries tfp-reasoned.csv tfps scanner-tfp "$REASONER_DATA"
fi

# Half-Spectre gadgets
if [ -f half.csv ]; then
    echo "== Half-Spectre ==" >> "$SCANNER_DATA"
    run_queries half.csv halfgadgets scanner-half-spectre "$SCANNER_DATA"
fi

# Remove trailing whitespace, to avoid differences that only consist of whitespace
find "$OUT_FOLDER" -type f -exec sed -i 's/[[:space:]]*$//' {} +

# ------------------------------------------------------------------------------
# Create ref folder if it does not exist

if [ ! -d "$OUT_REF_FOLDER" ]; then
    echo "[+] ref folder does not exist, creating it and skipping ${name}"
    rm -f "$OUT_REF_FOLDER"
    mv "$OUT_FOLDER" "$OUT_REF_FOLDER"
    rm -f -r "$ASM_REF_FOLDER"
    [ -d "$ASM_FOLDER" ] && mv "$ASM_FOLDER" "$ASM_REF_FOLDER"

    # We exit since we cannot compare
    exit 0
fi

# ------------------------------------------------------------------------------
# Perform diff

if ! git --no-pager diff --minimal --no-index --word-diff=color --word-diff-regex=. "$OUT_REF_FOLDER" "$OUT_FOLDER"; then
    # Folders differ
    echo -e "\e[31m[-] failed:   ${name}\e[0m"

    if [ "$do_update" -eq 1 ]; then
        echo "    Updating ref folders:  ${name}"
        rm -f -r "$OUT_REF_FOLDER"
        rm -f -r "$ASM_REF_FOLDER"
        mv "$OUT_FOLDER" "$OUT_REF_FOLDER"
        [ -d "$ASM_FOLDER" ] && mv "$ASM_FOLDER" "$ASM_REF_FOLDER"
    fi

    exit 1
else
    # Folders are equal
    echo "[+] passed:  ${name}"
    exit 0
fi
