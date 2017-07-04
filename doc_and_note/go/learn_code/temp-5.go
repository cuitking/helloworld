package main

import (
	"fmt"
)

func main() {
	a := 1
	var p *int = &a
	fmt.Println(*p)

	b := 10
	if b := 1; b > 1 {
		fmt.Println("bbbbb", b)
	}

	fmt.Println("---out----b----", b)

	c := 1
	for {
		c++
		if c > 3 {
			break
		}
		fmt.Println("cccccc", c)
	}
	fmt.Println("---C OVER---", c)

	d := 1
	for d <= 3 {
		d++
		fmt.Println("-----d-----", d)
	}
	fmt.Println("d---over---", d)

	e := 1
	for i := 0; i < 3; i++ {
		e++
		fmt.Println("---e-----", e)
	}
	fmt.Println("--------e------over------", e)

	switch f := 1; {
	case f >= 0:
		fmt.Println("f==0")
		fallthrough
	case f >= 1:
		fmt.Println("f==1")
	case f >= 2:
		fmt.Println("f==2")
	default:
		fmt.Println("noone")
	}

LABLE1:
	for {
		for i := 0; i < 10; i++ {
			if i > 3 {
				break LABLE1
			}
		}
	}
	fmt.Println("0K")
}
