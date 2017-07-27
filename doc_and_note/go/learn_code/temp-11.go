package main

import (
	"fmt"
)

type A struct {
	Name string
}

type B struct {
	Name string
}

type AZ int

type C struct {
	name string
}

func main() {
	fmt.Println("-----------11. method-----------")
	a := A{}
	a.Print()
	fmt.Println(a)

	b := B{}
	b.Print()
	fmt.Println("---b---", b)

	var aa AZ
	aa.Print()
	(*AZ).Print(&aa)

	fmt.Println("-----------------")
	c := C{}
	c.Print()
	fmt.Println("c-------", c)

	var ac AZ
	ac = 1
	ac.Increase(100)
	fmt.Println("-----ac------", ac)
}

func (a *A) Print() {
	a.Name = "fuck"
	fmt.Println("A")
}

func (b B) Print() {
	b.Name = "bbb"
	fmt.Println("bbbbb")
}

func (a *AZ) Print() {
	fmt.Println("show -----az print")
}

func (a *AZ) Increase(num int) {
	*a += AZ(num)
	fmt.Println("-----a--------", a)
}

func (a *C) Print() {
	a.name = "123"
	fmt.Println(a)
}
