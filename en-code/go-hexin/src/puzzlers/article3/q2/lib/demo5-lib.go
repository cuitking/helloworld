//package main
package lib5

//cp from demo4-lib.go

import (
	"fmt"
)

// func hello(name string) {
// 	fmt.Printf("Hello, %s\n", name)
// }
func Hello(name string) {
	fmt.Printf("hello, %s\n", name)
}

/*
源码库文件demo5-lib.go所在目录的相对路径是/puzzlers/article3/q2/lib，而它却声明为lib5包.
在这种情况下，该包导入的路径是/puzzlers/article3/q2/lib, 还是/puzzlers/article3/q2/lib5？

*/
