package main

import (
	"fmt"
)

func main() {
	fmt.Println("--------14.concurrency----------")
	///创建channel
	// runtime.GOMAXPROCS(runtime.NumCPU())
	// wg := sync.WaitGroup{}
	// wg.Add(10)
	// ///c := make(chan bool, 10) //双向通道

	// for i := 0; i < 10; i++ {
	// 	go Go(&wg, i)
	// }
	// wg.Wait()
	// for i := 0; i < 10; i++ {
	// 	<-c
	// }
	// go func() {
	// 	fmt.Println("gogo----------")
	// 	c <- true
	// 	close(c)
	// }()
	// for v := range c {
	// 	fmt.Println(v)

	// }
	//<-c
	//time.Sleep(2 * time.Second)

	// c1, c2 := make(chan int), make(chan string)
	// o := make(chan bool)
	// go func() {
	// 	for {
	// 		select {
	// 		case v, ok := <-c1:
	// 			if !ok {
	// 				o <- true
	// 				break
	// 			}
	// 			fmt.Println("c1----", v)
	// 		case v, ok := <-c2:
	// 			if !ok {
	// 				o <- true
	// 				break
	// 			}
	// 			fmt.Println("c2-----", v)
	// 		}
	// 	}

	// }()

	// c1 <- 1
	// c2 <- "hi"
	// c1 <- 3
	// c2 <- "hello"

	// close(c1)
	// //close(c2)

	// <-o
	c := make(chan int)
	go func() {
		for v := range c {
			fmt.Println(v)
		}
	}()

	for {
		select {
		case c <- 0:
		case c <- 1:
		}
	}

}

// func Go(wg *sync.WaitGroup, index int) {
// 	a := 1
// 	for i := 0; i < 100000000; i++
// 		a += i
// 	}
// 	fmt.Println(index, a)
// 	wg.Done()
// }

// func Go(c chan bool, index int) {
// 	a := 1
// 	for i := 0; i < 100000000; i++ {
// 		a += i
// 	}
// 	fmt.Println(index, a)
// 	c <- true
// }

// func Go() {

// 	fmt.Println("GO gogo!!!!!!!!")
// }
