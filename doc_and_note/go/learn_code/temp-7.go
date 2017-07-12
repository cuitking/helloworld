package main

import (
	"fmt"
)

func main() {
	var s1 []int
	fmt.Println(s1)

	a := [10]int{1, 2, 3, 4, 5, 6, 7, 8, 9}
	fmt.Println(a)
	s2 := a[5:]
	fmt.Println(s2)

	s3 := make([]int, 3, 10)
	fmt.Println("s3---------")
	fmt.Println(s3)
}
