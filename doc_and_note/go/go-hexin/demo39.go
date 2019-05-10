package main 

import (
		"fmt"
		//"time"
		)

func main() {
	num := 10
	sign := make(chan struct{}, num)
	for i := 0; i < 10; i++ {
		go func(i int) {
			fmt.Println(i)
			sign <- struct{}{}
		}(i)
	}
	//time.Sleep(time.Millisecond * 500)
	for j := 0; j < num; j++ {
		<- sign
	}
}