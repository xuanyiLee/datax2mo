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
# This script is used to load generated TPC-H data set into MatrixOne.
# for table lineitem, orders, partsupp, they will be loading in parallel
##############################################################

set -eo pipefail

ROOT=$(dirname "$0")
ROOT=$(
    cd "${ROOT}"
    pwd
)

CURDIR="${ROOT}"
TPCH_DATA_DIR="${CURDIR}/tpch-data"

usage() {
    echo "
Usage: $0 <options>
  Optional options:
     -c             parallelism to load data of lineitem, orders, partsupp, default is 5.

  Eg.
    $0              load data using default value.
    $0 -c 10        load lineitem, orders, partsupp table data using parallelism 10.     
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

# check if tpch-data exists
if [[ ! -d "${TPCH_DATA_DIR}"/ ]]; then
    echo "${TPCH_DATA_DIR} does not exist. Run sh gen-tpch-data.sh first."
    exit 1
fi

check_prerequest() {
    local CMD=$1
    local NAME=$2
    if ! ${CMD}; then
        echo "${NAME} is missing. This script depends on cURL to load data to MatrixOne."
        exit 1
    fi
}

check_prerequest "curl --version" "curl"

# load tables

export MYSQL_PWD=${PASSWORD}

echo "Parallelism: ${PARALLEL}"
echo "HOST: ${HOST}"
echo "PORT: ${PORT}"
echo "USER: ${USER}"
echo "DB: ${DB}"

function run_sql() {
    echo "$*"
    mysql -h"${HOST}" -u"${USER}" -P"${PORT}" -D"${DB}" -e "$*" --local-infile
}

# start load
start_time=$(date +%s)
echo "Start time: $(date)"

echo 'Loading data for table: region'
run_sql "load data local infile '${TPCH_DATA_DIR}/region.tbl' INTO TABLE region FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '|\n';"

echo 'Loading data for table: nation'
run_sql "load data local infile '${TPCH_DATA_DIR}/nation.tbl' INTO TABLE nation FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '|\n';"

echo 'Loading data for table: supplier'
run_sql "load data local infile '${TPCH_DATA_DIR}/supplier.tbl' INTO TABLE supplier FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '|\n';"

echo 'Loading data for table: customer'
run_sql "load data local infile '${TPCH_DATA_DIR}/customer.tbl' INTO TABLE customer FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '|\n';"

echo 'Loading data for table: part'
run_sql "load data local infile '${TPCH_DATA_DIR}/part.tbl' INTO TABLE part FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '|\n';"

# set parallelism

# 以PID为名, 防止创建命名管道时与已有文件重名，从而失败
fifo="/tmp/$$.fifo"
# 创建命名管道
mkfifo "${fifo}"
# 以读写方式打开命名管道，文件标识符fd为3，fd可取除0，1，2，5外0-9中的任意数字
exec 3<>"${fifo}"
# 删除文件, 也可不删除, 不影响后面操作
rm -rf "${fifo}"

# 在fd3中放置$PARALLEL个空行作为令牌
for ((i = 1; i <= PARALLEL; i++)); do
    echo >&3
done

date
for file in "${TPCH_DATA_DIR}"/lineitem.tbl*; do
    # 领取令牌, 即从fd3中读取行, 每次一行
    # 对管道，读一行便少一行，每次只能读取一行
    # 所有行读取完毕, 执行挂起, 直到管道再次有可读行
    # 因此实现了进程数量控制
    read -r -u3

    # 要批量执行的命令放在大括号内, 后台运行
    {
        run_sql "load data local infile '${file}' INTO TABLE lineitem FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '|\n';"
        echo "----loaded ${file}"
        sleep 2
        # 归还令牌, 即进程结束后，再写入一行，使挂起的循环继续执行
        echo >&3
    } &
done

date
for file in "${TPCH_DATA_DIR}"/orders.tbl*; do
    read -r -u3
    {
        run_sql "load data local infile '${file}' INTO TABLE orders FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '|\n';"
        echo "----loaded ${file}"
        sleep 2
        echo >&3
    } &
done

date
for file in "${TPCH_DATA_DIR}"/partsupp.tbl*; do
    read -r -u3
    {
        run_sql "load data local infile '${file}' INTO TABLE partsupp FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '|\n';"
        echo "----loaded ${file}"
        sleep 2
        echo >&3
    } &
done

# 等待所有的后台子进程结束
wait
# 删除文件标识符
exec 3>&-

end_time=$(date +%s)
echo "End time: $(date)"

echo "Finish load tpch data, Time taken: $((end_time - start_time)) seconds"


