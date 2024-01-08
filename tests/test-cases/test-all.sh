make clean
make

passed=0
total=0

for f in $(ls ./*/gadget)
do
    ./test-single.sh `dirname $f` $1

    if [ $? -eq 0 ]; then
        passed=$((passed+1))
    fi

    total=$((total+1))

done

echo '----------------------------------------------------------------------'
echo "Passed ${passed} out of ${total}"
