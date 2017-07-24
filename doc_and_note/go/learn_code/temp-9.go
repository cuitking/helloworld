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

	fmt.Println("a")

	defer fmt.Println("b")
	defer fmt.Println("c")

	for i := 0; i < 3; i++ {
		///defer fmt.Println("i", i)
		defer func() {
			fmt.Println(i)
		}()
	}

	fmt.Println("-------------")
	AA()
	BB()
	CC()

	//////////////////////////////////
	var fs = [4]func(){}

	for i := 0; i < 4; i++ {
		defer fmt.Println("defer-----", i)
		defer func() {
			fmt.Println("defer_closure i = ", i)
		}()
		fs[i] = func() {
			fmt.Println("closure i===", i)
		}
	}

	for _, f := range fs {
		f()
	}
}

// func A(a ...int) {
// 	a[0] = 3
// 	a[1] = 4
// 	fmt.Println(a)

// }

func AA() {
	fmt.Println("func aa")
}

func BB() {
	defer func() {
		if err := recover(); err != nil {
			fmt.Println("Recover in B")
		}
	}()
	panic("panic in BB")
}

func CC() {
	fmt.Println(" ----func C-----")
}

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
	fmt.Println(" %p", &x)
	return func(y int) int {
		fmt.Println(" %p", &x)
		return x + y
	}
}
