package main

import (
	"datax/conf"
	"fmt"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"os"
	"strings"
)

func main() {
	cfg := conf.NewConf("./conf/matrixone.ini")
	err := cfg.Load()
	if err != nil {
		panic(err)
	}

	mysqlConn, err := getDBConn("mysql")
	if err != nil {
		os.Exit(1)
	}

	moConn, err := getDBConn("matrixone")
	if err != nil {
		os.Exit(1)
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
		cnf = conf.MyCnf
	case "matrixone":
		cnf = conf.MoConf
	}
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8mb4&parseTime=True&loc=Local", cnf.Username, cnf.Password, cnf.HOST, cnf.Port, cnf.DataBase) //MO
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		fmt.Println(fmt.Sprintf("%s Database Connection Failed", dataSource)) //Connection failed
		return nil, err
	}
	fmt.Println("Database Connection Succeed") //Connection succeed

	return db, nil
}
