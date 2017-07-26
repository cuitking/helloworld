package main

import (
	"fmt"
)

type A struct{}

type B struct {
	Name string
}

func main() {
	fmt.Println("-----------11. method-----------")
	a := A{}
	a.Print()

	b := B{}
	b.Print()
}

func (a A) Print() {
	fmt.Println("A")
}

func (b B) Print() {
	fmt.Println("bbbbb")
}
