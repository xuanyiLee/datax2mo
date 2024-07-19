#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

##############################################################
# This script is used to load generated tpcc data set to MatrixOne
##############################################################

set -eo pipefail

ROOT=$(dirname "$0")
ROOT=$(
    cd "${ROOT}"
    pwd
)

CURDIR="${ROOT}"
TPCC_DATA_DIR="${CURDIR}/data/"

usage() {
    echo "
Usage: $0 <options>
  Optional options:
    -c             parallelism to load data of lineorder table, default is 5.

  Eg.
    $0              load data using default value.
    $0 -c 10        load lineorder table data using parallelism 10.     
  "
    exit 1
}

OPTS=$(getopt \
    -n "$0" \
    -o '' \
    -o 'hc:' \
    -- "$@")

eval set -- "${OPTS}"

PARALLEL=5
HELP=0

if [[ $# == 0 ]]; then
    usage
fi

while true; do
    case "$1" in
    -h)
        HELP=1
        shift
        ;;
    -c)
        PARALLEL=$2
        shift 2
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Internal error"
        exit 1
        ;;
    esac
done

if [[ "${HELP}" -eq 1 ]]; then
    usage
fi

echo "Parallelism: ${PARALLEL}"

# check if tpcc-data exists
if [[ ! -d ${TPCC_DATA_DIR}/ ]]; then
    echo "${TPCC_DATA_DIR} does not exist. Run sh gen-tpcc-data.sh first."
    exit 1
fi

run_sql() {
    sql="$*"
    echo "${sql}"
    mysql -h"${HOST}" -u"${USER}" -P"${PORT}" -D"${DB}" -e "$@" --local-infile
}

export MYSQL_PWD=${PASSWORD}

echo "HOST: ${HOST}"
echo "PORT: ${PORT}"
echo "USER: ${USER}"
echo "PASSWORD: ${PASSWORD}"
echo "DB: ${DB}"

start_time=$(date +%s)
echo "Start time: $(date)"
echo "==========Start to load data into tpcc tables=========="

echo 'Loading data for table: bmsql_config'
run_sql "load data local infile '${TPCC_DATA_DIR}/config.csv' INTO TABLE bmsql_config FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n';"

echo 'Loading data for table: bmsql_warehouse'
run_sql "load data local infile '${TPCC_DATA_DIR}/warehouse.csv' INTO TABLE bmsql_warehouse FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n';"

echo 'Loading data for table: bmsql_district'
run_sql "load data local infile '${TPCC_DATA_DIR}/district.csv' INTO TABLE bmsql_district FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n';"

echo 'Loading data for table: bmsql_customer'
run_sql "load data local infile '${TPCC_DATA_DIR}/customer.csv' INTO TABLE bmsql_customer FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n';"

echo 'Loading data for table: bmsql_history'
run_sql "load data local infile '${TPCC_DATA_DIR}/cust-hist.csv' INTO TABLE bmsql_history FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n';"

echo 'Loading data for table: bmsql_new_order'
run_sql "load data local infile '${TPCC_DATA_DIR}/new-order.csv' INTO TABLE bmsql_new_order FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n';"

echo 'Loading data for table: bmsql_oorder'
run_sql "load data local infile '${TPCC_DATA_DIR}/order.csv' INTO TABLE bmsql_oorder FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n';"

echo 'Loading data for table: bmsql_order_line'
run_sql "load data local infile '${TPCC_DATA_DIR}/order-line.csv' INTO TABLE bmsql_order_line FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n';"

echo 'Loading data for table: bmsql_item'
run_sql "load data local infile '${TPCC_DATA_DIR}/item.csv' INTO TABLE bmsql_item FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n';"

echo 'Loading data for table: bmsql_stock'
run_sql "load data local infile '${TPCC_DATA_DIR}/stock.csv' INTO TABLE bmsql_stock FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n';"

end_time=$(date +%s)
echo "End time: $(date)"

echo "Finish load tpcc data, Time taken: $((end_time - start_time)) seconds"
