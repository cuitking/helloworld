package main

import (
	"fmt"
)

var block = "package"

func main() {
	block := "function"
	block = "functiona"
	{
		//block := "inner"
		fmt.Printf("The block is %s. \n", block)
	}
	fmt.Printf("The block is %s. \n", block)
}
