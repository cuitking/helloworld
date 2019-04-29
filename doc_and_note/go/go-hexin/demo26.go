package main 

import (
		"fmt"
		"errors"
)

type Printer func(contents string) (n int, err error)

func printToStd(contents string) (bytesNum int, err error) {
	return fmt.Println(contents)
}

type operate func(x, y int) int

func calculate(x int, y int, op operate) (int, error) {
	if op == nil {
		return 0, errors.New("invalid operation")
	}
	return op(x, y), nil
}

type calculateFunc func(x int, y int) (int, error)

func genCalculator(op operate) calculateFunc {
	return func(x int, y int) (int, error) {
		if op == nil {
			return 0, errors.New("invalid operation")
		}
		return op(x, y), nil
	}
}


func modifyArray(a [3]string) [3]string {
	a[1] = "x"
	return a
}



func main() {
	var p Printer
	p = printToStd
	p("something ...")

	x, y := 12, 23
	op := func(x, y int) int{
		return x + y
	}
	over, err := calculate(x, y, op)
	fmt.Println("------over, err----", over, err)

	over, err = calculate(x, y, nil)
	fmt.Println("-------over, err--------", over, err)

	//方案2
	x, y = 56, 78
	add := genCalculator(op)
	result, erra := add(x,y)
	fmt.Printf("The result: %d (error: %v )\n", result, erra)


	array1 := [3]string{"a", "b", "c"}
	fmt.Printf("The array: %v\n", array1)
	array2 := modifyArray(array1)
	fmt.Printf("The modified array: %v\n", array2)
	fmt.Printf("The original array: %v\n", array1)
}