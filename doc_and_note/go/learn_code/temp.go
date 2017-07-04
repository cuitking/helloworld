package main

import (
	"fmt"
	"math"
	"strconv"
)

type (
	byte int8
	rune int32
	文本   string
)

func main() {
	var a int
	var abool bool
	fmt.Println("---------a-----", a)
	fmt.Println("----bool-------", abool)
	var astring string
	fmt.Println("------astring------", astring)
	var b [5]int
	fmt.Println("------b []int------", b)
	fmt.Println("---------maxInt32-----", math.MaxInt32)

	var bb = 1
	fmt.Println("bb", bb)
	cc := 2
	fmt.Println("cc", cc)

	var x, y, z, w int = 1, 2, 3, 4
	fmt.Println(x, y, z, w)
	c, d, e := 5, 6, 7
	fmt.Println(c, d, e)

	var aaa float32 = 101.2
	fmt.Println(aaa)
	bbb := int(aaa)
	fmt.Println("---bbb---", bbb)

	var as int = 65
	bs := string(as)
	bc := strconv.Itoa(as)
	fmt.Println("--bs---", bs, bc)
}
