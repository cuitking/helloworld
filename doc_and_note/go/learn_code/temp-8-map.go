package main

import (
	"fmt"
	"sort"
)

func main() {
	fmt.Println("----map------")
	///var m map[int]string = make(map[int]string)
	m := make(map[int]string)
	m[1] = "ok"

	fmt.Println(m)
	a := m[1]
	fmt.Println("---a---", a)

	delete(m, 1)
	fmt.Println("---delete -lll", m)

	var n map[int]map[int]string
	n = make(map[int]map[int]string)
	n[1] = make(map[int]string)
	n[1][1] = "ok"
	fmt.Println("nnnnnnn", n)
	b, ok := n[2][1]
	if !ok {
		n[2] = make(map[int]string)
	}
	n[2][1] = "good"
	b, ok = n[2][1]
	fmt.Println("---b---,ok---", b, ok)

	///---------------------------
	// for i, v := range slice {

	// }
	// sm := make([]map[int]string, 5)
	// for _, v := range sm {
	// 	v = make(map[int]string, 1)
	// 	v[1] = "fuck"
	// 	fmt.Println(v)
	// }
	// fmt.Println(sm)

	sm := make([]map[int]string, 5)
	for i := range sm {
		sm[i] = make(map[int]string, 1)
		sm[i][1] = "fuck"
		fmt.Println(sm[i])
	}
	fmt.Println(sm)

	///map 排序
	newm := map[int]string{1: "a", 2: "b", 3: "c", 4: "d", 5: "e"}
	ms := make([]int, len(newm))
	i := 0
	for k, _ := range newm {
		ms[i] = k
		i++
	}
	fmt.Println("newm-----", newm)
	fmt.Println("ms-------", ms)
	sort.Ints(ms)
	fmt.Println("sort---ms---", ms)
}
