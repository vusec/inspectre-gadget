make clean
make

for f in $(ls ./*/gadget)
do
    ./run-single.sh `dirname $f`
done
