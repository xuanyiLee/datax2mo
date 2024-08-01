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
		datax2mo.Cmd_ctl_output("./ssb/bin/gen-ssb-data.sh", "gen_data", "-s", cfg.Scale)
	case "tpch":
		datax2mo.Cmd_ctl_output("./tpch/bin/gen-tpch-data.sh", "gen_data", "-s", cfg.Scale)
	case "tpcc":
		datax2mo.Cmd_ctl_output("./tpcc/bin/runLoader.sh", "gen_data", "./tpcc/mysql.mo", "filelocation", "./tpcc/bin/data/")
	case "tpcds":
		datax2mo.Cmd_ctl_output("./tpcds/bin/gen-tpcds-data.sh", "gen_data", "-s", cfg.Scale)
	}

	os.Exit(0)
}
