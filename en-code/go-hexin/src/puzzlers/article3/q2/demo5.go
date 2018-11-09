// 代码拆分到其他源码文件 cp from demo4.go
package main

import (
	"flag"
)

var name string

func init() {
	flag.StringVar(&name, "name", "everyone", "The greeting object.")
}

func main() {
	flag.Parse()
	hello(name)
}

//  go run demo4.go demo4-lib.go

// 2 先构建当前代码包再运行 创建puzzlers/article3/q1
// go build puzzlers/article3/q1
// ./q1
