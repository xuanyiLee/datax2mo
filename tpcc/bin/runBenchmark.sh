#!/usr/bin/env bash

if [[ $# -gt 2 || $# -lt 1 ]] ; then
    echo "usage: $(basename $0) PROPS_FILE" >&2
    echo "usage: $(basename $0) PROPS_FILE PROFILE" >&2
    exit 2
fi

SEQ_FILE="./.jTPCC_run_seq.dat"
if [ ! -f "${SEQ_FILE}" ] ; then
    echo "0" > "${SEQ_FILE}"
fi
SEQ=$(expr $(cat "${SEQ_FILE}") + 1) || exit 1
echo "${SEQ}" > "${SEQ_FILE}"

source ./tpcc/bin/funcs.sh $1

setCP || exit 1

myOPTS="-Dprop=$1 -DrunID=${SEQ}"
echo "$myCP"

if [ $2 == "PROFILE" ]; then
  nohup ./profile.sh $1 > profile.log &
fi

java -cp "$myCP" $myOPTS io.mo.jTPCC 