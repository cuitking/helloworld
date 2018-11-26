package main

import (
	"fmt"
)

func main() {
	// sample 1
	s1 := make([]int, 5)
	fmt.Printf("the length of s1: %d\n", len(s1))
	fmt.Printf("the capacity of s1: %d \n", cap(s1))
	fmt.Printf("the value of s1: %d \n", s1)

	s2 := make([]int, 5, 8)
	fmt.Printf("the length of s2: %d\n", len(s2))
	fmt.Printf("the capacity of s2 : %d \n", cap(s2))
	fmt.Printf("the value of s2: %d \n", s2)
}
