package conf

import (
	"fmt"
	"gopkg.in/ini.v1"
	"os"
)

var Cfg *Conf
var MyCnf MysqlConf
var MoConf MysqlConf

type Conf struct {
	Filename string
	Type     string
	Scale    string
	Tables   string
	SplitKey string
}

type MysqlConf struct {
	HOST     string
	Port     int
	Username string
	Password string
	DataBase string
}

func NewConf(filename string) *Conf {
	Cfg = &Conf{Filename: filename}
	return Cfg
}

func (c *Conf) Load() error {
	cfg, err := ini.Load(c.Filename)
	if err != nil {
		return err
	}

	c.Type = cfg.Section("testOption").Key("type").String()
	c.Scale = cfg.Section("testOption").Key("scale").String()
	c.Tables = cfg.Section(c.Type).Key("table").String()
	c.SplitKey = cfg.Section(c.Type).Key("splitkey").String()

	err = c.loadMysqlConf(cfg, "mysql")
	if err != nil {
		return err
	}

	err = c.loadMysqlConf(cfg, "matrixone")
	if err != nil {
		return err
	}

	return nil
}

func (c *Conf) loadMysqlConf(cfg *ini.File, dataSource string) error {
	port, err := cfg.Section(dataSource).Key("port").Int()
	if err != nil {
		return err
	}

	sourceConf := MysqlConf{
		HOST:     cfg.Section(dataSource).Key("host").String(),
		Port:     port,
		Username: cfg.Section(dataSource).Key("username").String(),
		Password: cfg.Section(dataSource).Key("password").String(),
		DataBase: cfg.Section(dataSource).Key("database").String(),
	}
	switch dataSource {
	case "mysql":
		MyCnf = sourceConf
	case "matrixone":
		MoConf = sourceConf
	}

	return nil
}

func (c *Conf) CreatetpccConf() {
	file, err := os.OpenFile("./tpcc/props.mo", os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0666)
	if err != nil {
		fmt.Println("打开文件错误:", err)
		return
	}
	defer file.Close() // 确保文件在函数结束时关闭

	// 准备要写入的内容
	conn := fmt.Sprintf("jdbc:mysql://%s:%d/tpcc?characterSetResults=utf8&continueBatchOnError=false&useServerPrepStmts=true&alwaysSendSetIsolation=false&useLocalSessionState=true&zeroDateTimeBehavior=CONVERT_TO_NULL&failoverReadOnly=false&serverTimezone=Asia/Shanghai&useSSL=false&socketTimeout=60000\n", MyCnf.HOST, MyCnf.Port)
	content := "db=mo\ndriver=com.mysql.cj.jdbc.Driver\nconn=" + conn + "user=" + MyCnf.Username + "\npassword=" + MyCnf.Password + "\nwarehouses=" + c.Scale + "\nloadWorkers=4"

	// 使用 WriteString 方法写入字符串
	_, err = file.WriteString(content)
	if err != nil {
		fmt.Println("写入文件错误:", err)
		return
	}

	fmt.Println("内容写入文件成功！")
}
