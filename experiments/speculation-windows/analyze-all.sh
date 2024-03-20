
for file in $1/*$2*.txt
do
    echo "================================="
    echo $file
    python3 analyze-spec-window-result.py $file
done
