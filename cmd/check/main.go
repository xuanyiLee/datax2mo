package main

import (
	"datax/conf"
	"datax/pkg"
	"fmt"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"net/url"
	"os"
	"strings"
	"time"
)

var mysqlCnf conf.MysqlConf
var moCnf conf.MysqlConf

func main() {
	cfg := conf.NewConf("./conf/matrixone.ini")
	err := cfg.Load()
	if err != nil {
		panic(err)
	}

	mysqlCnf = conf.MyCnf
	moCnf = conf.MoConf

	mysqlCnf.Password, moCnf.Password = pkg.GetPwd()
	mysqlConn, err := getDBConn("mysql")
	if err != nil {
		os.Exit(1)
	}
	moConn, err := getDBConn("matrixone")
	if err != nil {
		os.Exit(1)
	}

	switch cfg.Type {
	case "ssb":
		moTime := ssbQuery(moConn)
		mysqlTime := ssbQuery(mysqlConn)
		if mysqlTime < moTime {
			fmt.Println(fmt.Sprintf("[query time error]:mysql time %v,mo time %v", mysqlTime, moTime))
			os.Exit(1)
		}
	case "tpch":
		moTime := tpchQuery(moConn)
		mysqlTime := tpchQuery(mysqlConn)
		if mysqlTime < moTime {
			fmt.Println(fmt.Sprintf("[query time error]:mysql time %v,mo time %v", mysqlTime, moTime))
			os.Exit(1)
		}
	case "tpcc":
		mysqlTpmc := pkg.Cmd_ctl_output("./tpcc/bin/runBenchmark.sh", "tpcc_query", "./tpcc/mysql.mo")
		moTpmc := pkg.Cmd_ctl_output("./tpcc/bin/runBenchmark.sh", "tpcc_query", "./tpcc/matrixone.mo")
		if mysqlTpmc > moTpmc {
			fmt.Println(fmt.Sprintf("[query time error]:mysql tpmC %v,mo tpmC %v", mysqlTpmc, moTpmc))
			os.Exit(1)
		}
	case "tpcds":

	}

	arr := strings.Split(cfg.Tables, ",")
	var mysqlNum, moNum int64
	for _, table := range arr {
		mysqlConn.Table(table).Count(&mysqlNum)
		moConn.Table(table).Count(&moNum)
		if mysqlNum != moNum {
			fmt.Println(fmt.Sprintf("[Inconsistent data error]:%s table mysql num %v,mo num %v", table, mysqlNum, moNum))
			os.Exit(1)
		}
		mysqlNum = 0
		moNum = 0
	}

	os.Exit(0)
}

func getDBConn(dataSource string) (*gorm.DB, error) {
	var cnf conf.MysqlConf
	switch dataSource {
	case "mysql":
		cnf = mysqlCnf
	case "matrixone":
		cnf = moCnf
	}

	username := url.QueryEscape(cnf.Username)
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8mb4&parseTime=True&loc=Local", username, cnf.Password, cnf.HOST, cnf.Port, cnf.DataBase) //MO
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		fmt.Println(fmt.Sprintf("%s Database Connection Failed", dataSource)) //Connection failed
		return nil, err
	}
	fmt.Println("Database Connection Succeed") //Connection succeed

	return db, nil
}

func ssbQuery(db *gorm.DB) float64 {
	arr := []string{"1.1", "1.2", "1.3", "2.1", "2.2", "2.3", "3.1", "3.2", "3.3", "3.4", "4.1", "4.2", "4.3"}
	var total float64
	for _, v := range arr {
		var min float64 = 86400
		for j := 0; j < 3; j++ {
			start := time.Now()
			file := fmt.Sprintf("./ssb/ssb-queries/q%s.sql", v)
			data, err := os.ReadFile(file)
			if err != nil {
				fmt.Println(fmt.Sprintf("%s query fail err:%v", v, err))
				os.Exit(1)
			}
			sql := string(data)
			err = db.Exec(sql).Error
			if err != nil {
				fmt.Println(fmt.Sprintf("%s query fail err:%v", v, err))
			}
			seconds := time.Since(start).Seconds()
			if seconds < min {
				min = seconds
			}
		}
		total = total + min
	}
	return total
}

func tpchQuery(db *gorm.DB) float64 {
	var total float64
	for i := 1; i <= 22; i++ {
		var min float64 = 86400
		for j := 0; j < 3; j++ {
			start := time.Now()
			file := fmt.Sprintf("./tpch/queries/q%d.sql", i)
			data, err := os.ReadFile(file)
			if err != nil {
				fmt.Println(fmt.Sprintf("%d query fail err:%v", i, err))
				os.Exit(1)
			}
			sql := string(data)
			err = db.Exec(sql).Error
			if err != nil {
				fmt.Println(fmt.Sprintf("%d query fail err:%v", i, err))
			}
			seconds := time.Since(start).Seconds()
			if seconds < min {
				min = seconds
			}
		}
		total = total + min
	}
	return total
}
