package main 

import ("fmt"
		"math/rand"
		"time"
)

func main() {
	example1()
	example2()
}

// 示例1
func example1() {
	rand.Seed(time.Now().UnixNano())
	//准备好几个通道
	intChannels := [3]chan int{
		make(chan int, 1),
		make(chan int, 1),
		make(chan int, 1),
	}
	//随机选择一个通道并发送元素
	index := rand.Intn(3)
	fmt.Printf("The index: %d \n", index)
	intChannels[index] <- index
	// 哪一个通道中有可取的元素值，哪个对应的分支就会别执行
	select {
	case <- intChannels[0]:
		fmt.Println(" the first candidate case is selected.")
	case <- intChannels[1]:
		fmt.Println("the second candidate case is selected.")
	case elem := <- intChannels[2]:
		fmt.Printf("the third candidate case is selected, the element is  %d \n", elem)
	default:
		fmt.Println(" NO candidate case is selected")
	}

}
//示例2
func example2() {
	intChan := make(chan int, 1)
	// 一秒钟后通道关闭
	time.AfterFunc(time.Second, func() {
			close(intChan)
		})
	select {
	case _, ok := <-intChan:
		if !ok {
			fmt.Println("the candidate case is closed.")
			break
		}
		fmt.Println("The candidate case is selected.")
	}
}
