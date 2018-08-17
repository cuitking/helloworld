package main

import (
	"fmt"
)

func bubble_sort(arr []int, size int) {
	for i := 0; i < size-1; i++ {
		for j := 0; j < size-i-1; j++ {
			if arr[j] > arr[j+1] {
				arr[j], arr[j+1] = arr[j+1], arr[j]
			}
		}
	}
	fmt.Println(len(arr))
}

func main() {
	fmt.Println("--hello world---")
	arr := []int{0, 0, 0, 0, 0}
	for i, v := range arr {
		fmt.Println(i, v)
		arr[i] = len(arr) - i
	}

	for i, v := range arr {
		fmt.Println(i, v)
	}
	bubble_sort(arr, len(arr))
	for i, v := range arr {
		fmt.Println(i, v)
	}
}
