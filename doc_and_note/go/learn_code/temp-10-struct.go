package main

import (
	"fmt"
)

type person struct {
	Name    string
	Age     int
	Contact struct {
		Phone, City string
	}
}

type human struct {
	Sex int
}
type teacher struct {
	human
	Name string
	Age  int
}

type student struct {
	human
	Name string
	Age  int
}

func main() {
	fmt.Println("-------struct-----function----------")
	//a := person{}
	a := &person{
		Name: "joe",
		Age:  22,
	}
	a.Name = "fuckaaa"
	fmt.Println(a)
	A(a)
	B(a)
	fmt.Println(a)

	b := &struct {
		Name string
		Age  int
	}{
		Name: "jacke",
		Age:  99,
	}
	fmt.Println("----b--", b)

	c := person{Name: "andy", Age: 20}
	c.Contact.Phone = "1528"
	c.Contact.City = "chengdu"
	fmt.Println("-----c-----", c)

	fmt.Println("----------------------------")
	d := teacher{Name: "joaaa", Age: 9, human: human{Sex: 2}}
	e := student{Name: "student", Age: 19}

	fmt.Println("---------d---------", d)
	fmt.Println("---------e---------", e)
}

func A(per *person) {
	per.Age = 13
	fmt.Println("A---", per)
}

func B(per *person) {
	per.Age = 15
	fmt.Println("B---", per)
}
