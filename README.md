# 密码设置

为了安全需要，在github action设置repository security，mysqlpwd,mopwd分别设置mysql、MatrixOne的密码

# Mysql&MatrixOne设置

编辑conf下的matrixone.ini，分别设置mysql、matrixone数据库的相关信息，在测试选项（testOption）中填写要使用的数据集，目前支持tpcc、ssb、tpch、tpcds，数据大小支持1、10、100、1000G，需要调整时，修改配置文件提交即可

```
[mysql]
host='192.168.110.58'
port=3306
username='root'
# The database where test tables located
database='ssb'

[matrixone]
host='freetier-01.cn-hangzhou.cluster.matrixonecloud.cn'
port=6001
username='1af94fff_9a6c_4008_a946_4d15036618e1:admin:accountadmin'
# The database where test tables located
database='ssb'

[testOption]
# [tpcc、tpch、ssb、tpcds]
type='ssb'
# [1,10,100,1000]
scale='1'
```

# 建表

手动触发建表（create table for mysql）action，完成在mysql、matrixone中的建表

# 创建数据

手动触发（gen data && load data for mysql）action，完成生成数据，并把数据导入到mysql中，每次创建数据会先清空原先mysql中的数据

# 迁移数据&比较迁移结果

使用action定时任务触发datax把数据从mysql迁移matrixone中，迁移完成后比较迁移结果，执行时间为utc的每天16点。当mysql和matrixone中的数据量不一致时，查看action执行日志，会有类似如下提示：

```
[Inconsistent data error]:lineorder table mysql num 6001215,mo num 5370379
```





 
