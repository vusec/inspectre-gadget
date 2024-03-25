# Get first the coverage report
# e.g., wget https://storage.googleapis.com/syzkaller/cover/ci-qemu-upstream.html

if [ -z "$1" ]
  then
    echo "Usage: ./$(basename -- "$0") <coverage_report.html>"
    exit
fi

awk '/function_0/ {seen = 1} seen {print}' $1 | grep -v "<span class='hover'>SUMMARY" | awk -F"<span class='hover'>" '{print $2}' | awk NF | awk -F'[<> ]' '{print $1 " " $5}' | grep -v -e "---" | cut -d" " -f1
