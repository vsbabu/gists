#!/bin/bash

###########################################
#
# 1. adjust MAXQ and MAXFS below.
# 2. Adjust process inside process_one_file.sh
#    here is an example file to simulate sleep and a CPU intensive processing
#   #!/bin/bash
#   sleep $[ ( $RANDOM % 10 )  + 1 ]s
#   bzip2 $1
# 3. <thisscript.sh> input_file_name
#
###########################################
inf=$1

MAXQ=10      #how many queues to process concurrently?
MAXFS=1000   #how many records should be processed in one run?
PREFIX="pp"

echo "split -l $MAXFS $inf"

rm -f ${PREFIX}*
split -l $MAXFS $inf $PREFIX


QDIR=`mktemp -d`
echo "Queues at $QDIR"
maxqd=$((MAXQ - 1))
for i in `seq 0 $maxqd`; do
  qd="${QDIR}/q$i"
  mkdir -p $qd
done

SECONDS=0
while read -a l; do
  for i in `seq 0 $maxqd`; do
    qd="${QDIR}/q$i"
    if [[ -f ${l[$i]} ]]; then
      NQDIR=${qd} nq ./process_one_file.sh ${l[$i]} &> ${QDIR}/${l[$i]}.log
    fi
  done
done < <(ls ${PREFIX}*|xargs -n $MAXQ)

#waits - output shown for this is misleading because
# it doesn't do parallel waits. Nevertheless, it will make sure
# it is waiting till all files are done.
#Also, it DOES not process exit status
# if you don't want to wait, you can comment it out or CTRL-C as many times as there
# are processes to get out - in this case, only waiting is aborted; jobs will continue as is
for i in `seq 0 $maxqd`; do
    qd="${QDIR}/q$i"
    NQDIR=${qd} fq -q
done

# add your code here to merge generated split files and clean up split files
echo "$SECONDS seconds taken totally"