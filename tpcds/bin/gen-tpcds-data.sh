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
# This script is used to generate TPC-DS data set
##############################################################

set -eo pipefail

ROOT=$(dirname "$0")
ROOT=$(
    cd "${ROOT}"
    pwd
)

CURDIR=${ROOT}
TPCDS_DBGEN_DIR=${CURDIR}/tpcds-dbgen
TPCDS_DATA_DIR=${CURDIR}/tpcds-data

usage() {
    echo "
Usage: $0 <options>
  Optional options:
     -s             scale factor, default is 100
     -c             parallelism to generate data of lineorder table, default is 10

  Eg.
    $0              generate data using default value.
    $0 -s 10        generate data with scale factor 10.
    $0 -s 10 -c 5   generate data with scale factor 10. And using 5 threads to generate data concurrently.
  "
    exit 1
}

OPTS=$(getopt \
    -n "$0" \
    -o '' \
    -o 'hs:c:' \
    -- "$@")

eval set -- "${OPTS}"

SCALE_FACTOR=100
PARALLEL=10
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
    -s)
        SCALE_FACTOR=$2
        shift 2
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

echo "Scale Factor: ${SCALE_FACTOR}"
echo "Parallelism: ${PARALLEL}"

# check if dbgen exists
if [[ ! -f ${TPCDS_DBGEN_DIR}/dsdgen ]]; then
    echo "${TPCDS_DBGEN_DIR}/dsdgen does not exist."
    exit 1
fi

if [[ -d ${TPCDS_DATA_DIR}/ ]]; then
    rm -rf "${TPCDS_DATA_DIR}"
fi

mkdir "${TPCDS_DATA_DIR}/"

# gen data
date
cd "${TPCDS_DBGEN_DIR}"
echo "Begin to generate data for table: call_center"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE call_center
echo -e "\nBegin to generate data for table: catalog_page"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE catalog_page
echo -e "\nBegin to generate data for table: catalog_sales"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE catalog_sales
echo -e "\nBegin to generate data for table: customer"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE customer
echo -e "\nBegin to generate data for table: customer_address"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE customer_address
echo -e "\nBegin to generate data for table: customer_demographics"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE customer_demographics
echo -e "\nBegin to generate data for table: date_dim"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE date_dim
echo -e "\nBegin to generate data for table: dbgen_version"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE dbgen_version
echo -e "\nBegin to generate data for table: household_demographics"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE household_demographics
echo -e "\nBegin to generate data for table: income_band"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE income_band
echo -e "\nBegin to generate data for table: inventory"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE inventory
echo -e "\nBegin to generate data for table: item"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE item
echo -e "\nBegin to generate data for table: promotion"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE promotion
echo -e "\nBegin to generate data for table: reason"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE reason
echo -e "\nBegin to generate data for table: ship_mode"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE ship_mode
echo -e "\nBegin to generate data for table: store"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE store
echo -e "\nBegin to generate data for table: store_sales"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE store_sales
echo -e "\nBegin to generate data for table: time_dim"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE time_dim
echo -e "\nBegin to generate data for table: warehouse"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE warehouse
echo -e "\nBegin to generate data for table: web_page"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE web_page
echo -e "\nBegin to generate data for table: web_sales"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE web_sales
echo -e "\nBegin to generate data for table: web_site"
"${TPCDS_DBGEN_DIR}/dsdgen" -DIR "${TPCDS_DATA_DIR}/" -SCALE "${SCALE_FACTOR}" -TABLE web_site
date


