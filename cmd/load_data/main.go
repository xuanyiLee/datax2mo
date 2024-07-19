package main

import (
	"datax/conf"
	datax2mo "datax/pkg"
	"os"
)

func main() {
	cfg := conf.NewConf("./conf/matrixone.ini")
	err := cfg.Load()
	if err != nil {
		panic(err)
	}

	switch cfg.Type {
	case "ssb":
		datax2mo.Cmd_ctl_output("./ssb/bin/load-ssb-data.sh", "load_data")
	case "tpch":
		datax2mo.Cmd_ctl_output("./tpch/bin/load-tpch-data.sh", "load_data")
	case "tpcc":
		datax2mo.Cmd_ctl_output("./tpcc/bin/load-tpcc-data.sh", "load_data")
	case "tpcds":
		datax2mo.Cmd_ctl_output("./tpcds/bin/load-tpcds-data.sh", "load_data")
	}

	os.Exit(0)
}
