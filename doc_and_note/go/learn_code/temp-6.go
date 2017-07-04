package main

//6.数组array

import (
	"fmt"
)

func main() {
	a := [20]int{19: 2}
	fmt.Println(a)

	b := [...]int{1, 2, 3, 4, 5, 6}
	fmt.Println(b)

	c := [...]int{20: 3}
	fmt.Println(c)

	d := [2]int{1, 2}
	e := [2]int{1, 2}
	fmt.Println(d == e)

	p := new([10]int)
	p[2] = 2
	fmt.Println("p ====", p)
	q := [10]int{}
	q[2] = 2
	fmt.Println("q====", q)

	r := [...][3]int{
		{1, 2, 3},
		{4, 5, 6}}
	fmt.Println("r====", r)
}
