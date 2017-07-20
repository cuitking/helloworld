package main

import (
	"fmt"
)

func main() {
	fmt.Println("-------9.function-------")
	// a, b := 1, 2
	// A(a, b)
	// fmt.Println(a, b)
	s1 := []int{1, 2, 3, 4}
	A(s1)
	fmt.Println("-----s1------", s1)
	a := B
	a()
	//匿名函数
	b := func() {
		fmt.Println("---匿名b----")
	}
	b()

	//调用闭包
	fmt.Println("-----调用闭包-------")
	f := closure(10)
	fmt.Println(f(1))
	fmt.Println(f(2))
}

// func A(a ...int) {
// 	a[0] = 3
// 	a[1] = 4
// 	fmt.Println(a)

// }

func A(s []int) {
	s[0] = 5
	s[1] = 6
	s[2] = 7
	s[3] = 8
	fmt.Println(s)
}

func B() {
	fmt.Println("----B---- func B----")
}

///闭包
func closure(x int) func(int) int {
	return func(y int) int {
		return x + y
	}
}
