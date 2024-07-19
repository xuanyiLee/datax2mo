package main

import (
	"datax/conf"
	datax2mo "datax/pkg"
	"fmt"
	"os"
	"strings"
	"sync"
)

func main() {
	cfg := conf.NewConf("./conf/matrixone.ini")
	err := cfg.Load()
	if err != nil {
		panic(err)
	}

	mysqlPwd, moPwd := datax2mo.GetPwd()

	limit := make(chan struct{}, 5)
	tableArr := strings.Split(cfg.Tables, ",")
	keyArr := strings.Split(cfg.SplitKey, ",")
	var wg sync.WaitGroup

	for i, table := range tableArr {
		wg.Add(1)
		go func(i int, table string) {
			defer wg.Done()
			arg := fmt.Sprintf("-Dsplitkey=%s -Dr_ip=%s -Dr_port=%d -Dr_username=%s -Dr_password=%s -Dr_dbname=%s -Dtable=%s -Dw_ip=%s -Dw_port=%d -Dw_username=%s -Dw_password=%s -Dw_dbname=%s", keyArr[i], conf.MyCnf.HOST, conf.MyCnf.Port, conf.MyCnf.Username, mysqlPwd, conf.MyCnf.DataBase, table, conf.MoConf.HOST, conf.MoConf.Port, conf.MoConf.Username, moPwd, conf.MoConf.DataBase)
			fmt.Println(arg)
			limit <- struct{}{}
			args := []string{
				"./datax/bin/datax.py",
				"./datax/job/mysql2mo.json",
				"-p",
				arg,
			}

			datax2mo.Cmd_ctl_output("python", "", args...)
			<-limit
		}(i, table)
	}

	wg.Wait()
	os.Exit(0)
}
