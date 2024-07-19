#!/usr/bin/env bash

if [ $# -lt 1 ] ; then
    echo "usage: $(basename $0) PROPS_FILE [ARGS]" >&2
    exit 2
fi

source ./tpcc/bin/funcs.sh $1
shift

setCP || exit 1

java -cp "$myCP" -Dprop=$PROPS io.mo.LoadData $*
