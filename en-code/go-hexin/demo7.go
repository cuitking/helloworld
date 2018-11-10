package main

import (
	"flag"
	"fmt"
)

func main() {
	//var name string // [1]
	//flag.StringVar(&name, "name", "everyone", "The greeting object. ") // [2]
	//var name = *flag.String("name", "everyone", "The greeting object. ")
	//name := *flag.String("name", "everyone", "The greeting object.")
	var name = *getTheFlag()
	flag.Parse()
	fmt.Printf("hello, %v", name)
}

func getTheFlag() *string {
	return flag.String("name", "everyone", "The greeting object.")
}
