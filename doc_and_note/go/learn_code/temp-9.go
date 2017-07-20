package main

import (
	"fmt"
)

func main() {
	fmt.Println("-------9.function-------")
	a, b := 1, 2
	A(a, b)
	fmt.Println(a, b)
}

func A(a ...int) {
	a[0] = 3
	a[1] = 4
	fmt.Println(a)

}
