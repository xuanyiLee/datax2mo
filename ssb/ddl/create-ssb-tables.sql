CREATE TABLE IF NOT EXISTS `lineorder` (
  `lo_orderkey` int(11) NOT NULL COMMENT "",
  `lo_linenumber` int(11) NOT NULL COMMENT "",
  `lo_custkey` int(11) NOT NULL COMMENT "",
  `lo_partkey` int(11) NOT NULL COMMENT "",
  `lo_suppkey` int(11) NOT NULL COMMENT "",
  `lo_orderdate` date NOT NULL COMMENT "",
  `lo_orderpriority` varchar(16) NOT NULL COMMENT "",
  `lo_shippriority` int(11) NOT NULL COMMENT "",
  `lo_quantity` int(11) NOT NULL COMMENT "",
  `lo_extendedprice` int(11) NOT NULL COMMENT "",
  `lo_ordtotalprice` int(11) NOT NULL COMMENT "",
  `lo_discount` int(11) NOT NULL COMMENT "",
  `lo_revenue` int(11) NOT NULL COMMENT "",
  `lo_supplycost` int(11) NOT NULL COMMENT "",
  `lo_tax` int(11) NOT NULL COMMENT "",
  `lo_commitdate` date NOT NULL COMMENT "",
  `lo_shipmode` varchar(11) NOT NULL COMMENT ""
);

CREATE TABLE IF NOT EXISTS `customer` (
  `c_custkey` int(11) NOT NULL COMMENT "",
  `c_name` varchar(26) NOT NULL COMMENT "",
  `c_address` varchar(41) NOT NULL COMMENT "",
  `c_city` varchar(11) NOT NULL COMMENT "",
  `c_nation` varchar(16) NOT NULL COMMENT "",
  `c_region` varchar(13) NOT NULL COMMENT "",
  `c_phone` varchar(16) NOT NULL COMMENT "",
  `c_mktsegment` varchar(11) NOT NULL COMMENT ""
);

CREATE TABLE IF NOT EXISTS `dates` (
  `d_datekey` int(11) NOT NULL COMMENT "",
  `d_date` varchar(20) NOT NULL COMMENT "",
  `d_dayofweek` varchar(10) NOT NULL COMMENT "",
  `d_month` varchar(11) NOT NULL COMMENT "",
  `d_year` int(11) NOT NULL COMMENT "",
  `d_yearmonthnum` int(11) NOT NULL COMMENT "",
  `d_yearmonth` varchar(9) NOT NULL COMMENT "",
  `d_daynuminweek` int(11) NOT NULL COMMENT "",
  `d_daynuminmonth` int(11) NOT NULL COMMENT "",
  `d_daynuminyear` int(11) NOT NULL COMMENT "",
  `d_monthnuminyear` int(11) NOT NULL COMMENT "",
  `d_weeknuminyear` int(11) NOT NULL COMMENT "",
  `d_sellingseason` varchar(14) NOT NULL COMMENT "",
  `d_lastdayinweekfl` int(11) NOT NULL COMMENT "",
  `d_lastdayinmonthfl` int(11) NOT NULL COMMENT "",
  `d_holidayfl` int(11) NOT NULL COMMENT "",
  `d_weekdayfl` int(11) NOT NULL COMMENT ""
);

CREATE TABLE IF NOT EXISTS `supplier` (
  `s_suppkey` int(11) NOT NULL COMMENT "",
  `s_name` varchar(26) NOT NULL COMMENT "",
  `s_address` varchar(26) NOT NULL COMMENT "",
  `s_city` varchar(11) NOT NULL COMMENT "",
  `s_nation` varchar(16) NOT NULL COMMENT "",
  `s_region` varchar(13) NOT NULL COMMENT "",
  `s_phone` varchar(16) NOT NULL COMMENT ""
);

CREATE TABLE IF NOT EXISTS `part` (
  `p_partkey` int(11) NOT NULL COMMENT "",
  `p_name` varchar(23) NOT NULL COMMENT "",
  `p_mfgr` varchar(7) NOT NULL COMMENT "",
  `p_category` varchar(8) NOT NULL COMMENT "",
  `p_brand` varchar(10) NOT NULL COMMENT "",
  `p_color` varchar(12) NOT NULL COMMENT "",
  `p_type` varchar(26) NOT NULL COMMENT "",
  `p_size` int(11) NOT NULL COMMENT "",
  `p_container` varchar(11) NOT NULL COMMENT ""
);

CREATE TABLE IF NOT EXISTS `lineorder_flat` (
    `LO_ORDERDATE` date NOT NULL COMMENT "",
    `LO_ORDERKEY` int(11) NOT NULL COMMENT "",
    `LO_LINENUMBER` tinyint(4) NOT NULL COMMENT "",
    `LO_CUSTKEY` int(11) NOT NULL COMMENT "",
    `LO_PARTKEY` int(11) NOT NULL COMMENT "",
    `LO_SUPPKEY` int(11) NOT NULL COMMENT "",
    `LO_ORDERPRIORITY` varchar(100) NOT NULL COMMENT "",
    `LO_SHIPPRIORITY` tinyint(4) NOT NULL COMMENT "",
    `LO_QUANTITY` tinyint(4) NOT NULL COMMENT "",
    `LO_EXTENDEDPRICE` int(11) NOT NULL COMMENT "",
    `LO_ORDTOTALPRICE` int(11) NOT NULL COMMENT "",
    `LO_DISCOUNT` tinyint(4) NOT NULL COMMENT "",
    `LO_REVENUE` int(11) NOT NULL COMMENT "",
    `LO_SUPPLYCOST` int(11) NOT NULL COMMENT "",
    `LO_TAX` tinyint(4) NOT NULL COMMENT "",
    `LO_COMMITDATE` date NOT NULL COMMENT "",
    `LO_SHIPMODE` varchar(100) NOT NULL COMMENT "",
    `C_NAME` varchar(100) NOT NULL COMMENT "",
    `C_ADDRESS` varchar(100) NOT NULL COMMENT "",
    `C_CITY` varchar(100) NOT NULL COMMENT "",
    `C_NATION` varchar(100) NOT NULL COMMENT "",
    `C_REGION` varchar(100) NOT NULL COMMENT "",
    `C_PHONE` varchar(100) NOT NULL COMMENT "",
    `C_MKTSEGMENT` varchar(100) NOT NULL COMMENT "",
    `S_NAME` varchar(100) NOT NULL COMMENT "",
    `S_ADDRESS` varchar(100) NOT NULL COMMENT "",
    `S_CITY` varchar(100) NOT NULL COMMENT "",
    `S_NATION` varchar(100) NOT NULL COMMENT "",
    `S_REGION` varchar(100) NOT NULL COMMENT "",
    `S_PHONE` varchar(100) NOT NULL COMMENT "",
    `P_NAME` varchar(100) NOT NULL COMMENT "",
    `P_MFGR` varchar(100) NOT NULL COMMENT "",
    `P_CATEGORY` varchar(100) NOT NULL COMMENT "",
    `P_BRAND` varchar(100) NOT NULL COMMENT "",
    `P_COLOR` varchar(100) NOT NULL COMMENT "",
    `P_TYPE` varchar(100) NOT NULL COMMENT "",
    `P_SIZE` tinyint(4) NOT NULL COMMENT "",
    `P_CONTAINER` varchar(100) NOT NULL COMMENT ""
) ;