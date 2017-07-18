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
	fmt.Println(len(s3), cap(s3))

	sa := []byte{'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k'}
	ssa := sa[2:5]
	sb := ssa[3:5]
	fmt.Println("ssa---", string(ssa))
	fmt.Println("sb----", string(sb))
	alen := len(sa)

	sacopy := sa[0:alen]
	fmt.Println("sacopy---", string(sacopy))
}
