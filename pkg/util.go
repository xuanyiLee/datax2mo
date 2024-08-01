package pkg

import (
	"bufio"
	"datax/conf"
	"flag"
	"fmt"
	"io"
	"os"
	"os/exec"
	"strconv"
	"strings"
)

func GetPwd() (mysqlPwd string, moPwd string) {
	flag.StringVar(&mysqlPwd, "mysqlPwd", "1Qaz2wsx.", "password of mysql database")
	flag.StringVar(&moPwd, "moPwd", "1Qaz2wsx", "password of matrixone database")
	flag.Parse()

	if mysqlPwd == "" || moPwd == "" {
		fmt.Println(fmt.Sprintf("mysql passwprd:%s,mo password:%s", mysqlPwd, moPwd))
		os.Exit(1)
	}

	return mysqlPwd, moPwd
}

func Cmd(command string, arg ...string) {
	cmd := exec.Command(command, arg...)

	output, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Println(fmt.Sprintf("output:%s cmd fail: %v", string(output), err))
	}

	fmt.Println(string(output))
}

func Cmd_ctl_output(command string, operate string, arg ...string) float64 {
	cmd := exec.Command(command, arg...)

	if operate == "load_data" {
		myCnf := conf.MyCnf
		myCnf.Password, _ = GetPwd()
		cmd.Env = append(os.Environ(), "HOST="+myCnf.HOST, "PORT="+strconv.Itoa(myCnf.Port), "USER="+myCnf.Username, "PASSWORD="+myCnf.Password, "DB="+myCnf.DataBase)
	}

	// 创建一个管道来获取命令的输出
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		fmt.Println(fmt.Sprintf("get pipe of stdout error: %v", err))
		os.Exit(1)
	}
	stderr, err := cmd.StderrPipe()
	if err != nil {
		fmt.Println("")
		fmt.Println(fmt.Sprintf("get pipe of stderr error: %v", err))
		os.Exit(1)
	}

	// 开始执行命令
	if err = cmd.Start(); err != nil {
		fmt.Println(fmt.Sprintf("cmd start fail: %v", err))
		os.Exit(1)
	}

	// 创建一个bufio.Reader来逐行读取输出
	outreader := bufio.NewReader(stdout)
	for {
		line, err := outreader.ReadString('\n')
		if err != nil {
			if err == io.EOF {
				break
			}
			fmt.Println(fmt.Sprintf("read output err: %v", err))
			os.Exit(1)
		}
		fmt.Print(line)
		if operate == "tpcc_query" {
			if strings.Contains(line, "Measured tpmC") {
				arr := strings.Split(line, "=")
				result, err := strconv.ParseFloat(strings.TrimSpace(arr[1]), 64)
				if err != nil {
					fmt.Println(err)
				}
				return result
			}
		}
	}

	// 创建一个bufio.Reader来逐行读取输出
	reader := bufio.NewReader(stderr)
	for {
		line, err := reader.ReadString('\n')
		if err != nil {
			if err == io.EOF {
				break
			}
			fmt.Println(fmt.Sprintf("read output err: %v", err))
			os.Exit(1)
		}
		fmt.Print(line)
	}

	// 等待命令执行完成
	if err = cmd.Wait(); err != nil {
		fmt.Println(fmt.Sprintf("wait cmd run error: %v", err))
		os.Exit(1)
	}

	return 0
}
