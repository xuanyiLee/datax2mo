package main

import (
	"datax/conf"
	"flag"
	"fmt"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
	"net/url"
	"os"
	"strings"
)

var source, password string

func main() {
	cfg := conf.NewConf("./conf/matrixone.ini")
	err := cfg.Load()
	if err != nil {
		panic(err)
	}

	flag.StringVar(&source, "source", "mysql", "type of database")
	flag.StringVar(&password, "password", "1Qaz2wsx.", "password of database")
	flag.Parse()

	tableArr := strings.Split(cfg.Tables, ",")

	conn, err := getDBConn(source)
	if err != nil {
		os.Exit(1)
	}

	for _, table := range tableArr {
		err = conn.Exec("truncate table ?", clause.Table{Name: table}).Error
		if err != nil {
			fmt.Println(fmt.Sprintf("truncate table err: %v", err))
			os.Exit(1)
		}
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

	username := url.QueryEscape(cnf.Username)
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8mb4&parseTime=True&loc=Local", username, password, cnf.HOST, cnf.Port, cnf.DataBase) //MO
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		fmt.Println(fmt.Sprintf("%s Database Connection Failed", dataSource)) //Connection failed
		return nil, err
	}
	fmt.Println("Database Connection Succeed") //Connection succeed

	return db, nil
}
