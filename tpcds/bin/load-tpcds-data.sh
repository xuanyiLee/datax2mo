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
# This script is used to load generated tpcds data set to MatrixOne
##############################################################

set -eo pipefail

ROOT=$(dirname "$0")
ROOT=$(
    cd "${ROOT}"
    pwd
)

CURDIR="${ROOT}"
TPCDS_DATA_DIR="${CURDIR}/tpcds-data/"

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

# check if tpcds-data exists
if [[ ! -d ${TPCDS_DATA_DIR}/ ]]; then
    echo "${TPCDS_DATA_DIR} does not exist. Run sh gen-tpcds-data.sh first."
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
echo "==========Start to load data into tpcds tables=========="

echo 'Loading data for table: call_center'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/call_center.dat' INTO TABLE call_center FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: customer'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/customer.dat' INTO TABLE customer FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: income_band'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/income_band.dat' INTO TABLE income_band FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: ship_mode'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/ship_mode.dat' INTO TABLE ship_mode FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: warehouse'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/warehouse.dat' INTO TABLE warehouse FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: catalog_page'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/catalog_page.dat' INTO TABLE catalog_page FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: customer_demographics'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/customer_demographics.dat' INTO TABLE customer_demographics FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: inventory'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/inventory.dat' INTO TABLE inventory FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: store'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/store.dat' INTO TABLE store FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: web_page'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/web_page.dat' INTO TABLE web_page FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: catalog_returns'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/catalog_returns.dat' INTO TABLE catalog_returns FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: date_dim'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/date_dim.dat' INTO TABLE date_dim FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: item'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/item.dat' INTO TABLE item FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: store_returns'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/store_returns.dat' INTO TABLE store_returns FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: web_returns'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/web_returns.dat' INTO TABLE web_returns FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: catalog_sales'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/catalog_sales.dat' INTO TABLE catalog_sales FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: dbgen_version'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/dbgen_version.dat' INTO TABLE dbgen_version FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: promotion'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/promotion.dat' INTO TABLE promotion FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: store_sales'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/store_sales.dat' INTO TABLE store_sales FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: web_sales'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/web_sales.dat' INTO TABLE web_sales FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: customer_address'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/customer_address.dat' INTO TABLE customer_address FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: household_demographics'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/household_demographics.dat' INTO TABLE household_demographics FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: reason'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/reason.dat' INTO TABLE reason FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: time_dim'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/time_dim.dat' INTO TABLE time_dim FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

echo 'Loading data for table: web_site'
run_sql "LOAD DATA LOCAL INFILE '${TPCDS_DATA_DIR}/web_site.dat' INTO TABLE web_site FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n';"

end_time=$(date +%s)
echo "End time: $(date)"

echo "Finish load tpcds data, Time taken: $((end_time - start_time)) seconds"
