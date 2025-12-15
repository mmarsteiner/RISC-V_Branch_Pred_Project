#!/bin/bash
type=("scnt" "adpt")
typeorder=(0 1 0 1 0 1 0 1 0 1)
bitsorder=(1 1 2 2 4 4 8 8 16 16)
echo ""
rm results.txt
i=0
while [ $i -le 9 ]; do
    currtypeidx=${typeorder[i]}
    currtype=${type[currtypeidx]}
    currbits=${bitsorder[i]}
    file="bin/$currtype$currbits.vvp"
    echo "$currbits $currtype" >> results.txt
    echo "$currbits $currtype"
    vvp "$file"
    echo "" >> results.txt
    i=$((i+1))
done
