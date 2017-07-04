package main

import (
	"fmt"
)

const (
	a = 'A'
	b
	c = iota
	d
)

const (
	B float64 = 1 << (iota * 10)
	KB
	MB
	GB
	TB
)

func main() {
	fmt.Println(a)
	fmt.Println(b)
	fmt.Println(c)
	fmt.Println(d)
	fmt.Println(B, KB, MB, GB, TB)
}
