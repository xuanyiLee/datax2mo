drop table if exists lineitem;
CREATE TABLE lineitem (
    l_orderkey    bigint NOT NULL,
    l_partkey     int NOT NULL,
    l_suppkey     int not null,
    l_linenumber  int not null,
    l_quantity    decimal(15, 2) NOT NULL,
    l_extendedprice  decimal(15, 2) NOT NULL,
    l_discount    decimal(15, 2) NOT NULL,
    l_tax         decimal(15, 2) NOT NULL,
    l_returnflag  VARCHAR(1) NOT NULL,
    l_linestatus  VARCHAR(1) NOT NULL,
    l_shipdate    DATE NOT NULL,
    l_commitdate  DATE NOT NULL,
    l_receiptdate DATE NOT NULL,
    l_shipinstruct VARCHAR(25) NOT NULL,
    l_shipmode     VARCHAR(10) NOT NULL,
    l_comment      VARCHAR(44) NOT NULL,
    PRIMARY KEY (l_orderkey,l_linenumber)
);

drop table if exists orders;
CREATE TABLE orders  (
    o_orderkey       bigint NOT NULL,
    o_custkey        int NOT NULL,
    o_orderstatus    VARCHAR(1) NOT NULL,
    o_totalprice     decimal(15, 2) NOT NULL,
    o_orderdate      DATE NOT NULL,
    o_orderpriority  VARCHAR(15) NOT NULL,
    o_clerk          VARCHAR(15) NOT NULL,
    o_shippriority   int NOT NULL,
    o_comment        VARCHAR(79) NOT NULL,
    PRIMARY KEY (o_orderkey)
);

drop table if exists partsupp;
CREATE TABLE partsupp (
    ps_partkey          int NOT NULL,
    ps_suppkey     int NOT NULL,
    ps_availqty    int NOT NULL,
    ps_supplycost  decimal(15, 2)  NOT NULL,
    ps_comment     VARCHAR(199) NOT NULL,
    PRIMARY KEY (ps_partkey,ps_suppkey)
);

drop table if exists part;
CREATE TABLE part (
    p_partkey          int NOT NULL,
    p_name        VARCHAR(55) NOT NULL,
    p_mfgr        VARCHAR(25) NOT NULL,
    p_brand       VARCHAR(10) NOT NULL,
    p_type        VARCHAR(25) NOT NULL,
    p_size        int NOT NULL,
    p_container   VARCHAR(10) NOT NULL,
    p_retailprice decimal(15, 2) NOT NULL,
    p_comment     VARCHAR(23) NOT NULL,
    PRIMARY KEY (p_partkey)
);

drop table if exists customer;
CREATE TABLE customer (
    c_custkey     int NOT NULL,
    c_name        VARCHAR(25) NOT NULL,
    c_address     VARCHAR(40) NOT NULL,
    c_nationkey   int NOT NULL,
    c_phone       VARCHAR(15) NOT NULL,
    c_acctbal     decimal(15, 2)   NOT NULL,
    c_mktsegment  VARCHAR(10) NOT NULL,
    c_comment     VARCHAR(117) NOT NULL,
    PRIMARY KEY (c_custkey)
);

drop table if exists supplier;
CREATE TABLE supplier (
    s_suppkey       int NOT NULL,
    s_name        VARCHAR(25) NOT NULL,
    s_address     VARCHAR(40) NOT NULL,
    s_nationkey   int NOT NULL,
    s_phone       VARCHAR(15) NOT NULL,
    s_acctbal     decimal(15, 2) NOT NULL,
    s_comment     VARCHAR(101) NOT NULL,
    PRIMARY KEY (s_suppkey)
);

drop table if exists nation;
CREATE TABLE `nation` (
  `n_nationkey` int(11) NOT NULL,
  `n_name`      varchar(25) NOT NULL,
  `n_regionkey` int(11) NOT NULL,
  `n_comment`   varchar(152) NULL,
  PRIMARY KEY (n_nationkey)
);

drop table if exists region;
CREATE TABLE region  (
    r_regionkey      int NOT NULL,
    r_name       VARCHAR(25) NOT NULL,
    r_comment    VARCHAR(152),
    PRIMARY KEY (r_regionkey)
);

drop view if exists revenue0;
create view revenue0 (supplier_no, total_revenue) as
select
    l_suppkey,
    sum(l_extendedprice * (1 - l_discount))
from
    lineitem
where
    l_shipdate >= date '1996-01-01'
    and l_shipdate < date '1996-01-01' + interval '3' month
group by
    l_suppkey;
