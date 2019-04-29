package main 

import "fmt"

func main() {
	// 示例1
	ch1 := make(chan int, 1)
	ch1 <- 1
	fmt.Println("----------sample1----------")
	// ch1 <- 2 // 通道已满,这里会阻塞
	fmt.Println("----------is  zuse----------")

	// 示例2
	ch2 := make(chan int, 1)
	fmt.Println("---------ch2----before----")
	//elem, ok := <- ch2 // 通道一空，这里会阻塞
	//_, _ = elem, ok
	ch2 <- 1
	fmt.Println("---------ch2 ----after-----")
	// 示例3
	var ch3 chan int
	//ch3 <- 1
	fmt.Println("1111111")
	//<- ch3
	fmt.Println("-9999999999999----")
	_ = ch3
}