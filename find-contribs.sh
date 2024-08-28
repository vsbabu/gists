#!/bin/bash
# Output is like yyyy-mm-dd nn where nn is the count of commits by the person across repos in the current folder
WHOM="${1:-vsbabu}"
OP=`mktemp`
for f in `find . -name '.git'`; do 
 cd $f
 cd ..
 git log  --date=format:'%Y-%m-%d' --pretty=format:'%ad%x09%an'  |sed '1 i\dt\ttx' |grep -i $WHOM|awk '{print $1;}' >> $OP
 cd ..
done
cat $OP|sort|uniq -c|awk '{print $2, $1;}'
rm -f $OP
