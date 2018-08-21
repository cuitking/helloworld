package main

import (
	"flag"
	"fmt"
	"os"
)

var name string

func init() {
	//
	flag.StringVar(&name, "name", "everyone", "The greeting object.")
	/*
		函数flag.StringVar接受 4 个参数。第 1 个参数是用于存储命令参数的值的地址，具体
		到这里就是在前面声明的name的地址，由表达式&name表示
		第2个参数是为了指定该命令参数的名称，这里是name 第3个参数是 为了指定在未追加该命令
		时的默认值，这里是everyone。第4个参数是该命令参数的简短说明。
		还有一个和flag.StringVar类似的函数, flag.String。 这两个函数的区别是后者会直接返回
		一个已经分配好的用于存储命令参数值的地址。
		var name = flag.String("name", "everyone","The greeting object.")
	*/

}

func main() {
	//自定义命令源码文件的参数使用说明
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage of %s, \n", "questiong")
		flag.PrintDefaults()
	}

	flag.Parse()
	/*
		函数flag.Parse()用于真正解析命令参数,并把它们赋值给相应的变量
		对该函数的调用必须在所有命令参数存储载体的声明和设置之后，并且在读取任何命令参数值之前进行.
	*/
	fmt.Printf("hello, %s \n", name)
}
