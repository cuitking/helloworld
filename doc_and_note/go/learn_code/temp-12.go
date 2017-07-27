package main

import (
	"fmt"
)

type empty interface {
}

type USB interface {
	Name() string
	Connector
}

type Connector interface {
	Connect()
}

type PhoneConnector struct {
	name string
}

func (pc PhoneConnector) Name() string {
	return pc.Name()
}

func (pc PhoneConnector) Connect() {
	fmt.Println("connect----", pc.name)
}
func main() {
	// fmt.Println("----------12.interface---------")
	// a := PhoneConnector{"phoneconnector"}
	// a.Connect()
	// Disconnect(a)

	pc := PhoneConnector{"PhoneConnector"}
	var a Connector
	a = Connector(pc)
	a.Connect()

}

func Disconnect(usb interface{}) {
	// if pc, ok := usb.(PhoneConnector); ok {
	// 	fmt.Println("----Disconnected-----", pc.name)
	// 	return
	// }
	switch v := usb.(type) {
	case PhoneConnector:
		fmt.Println("----Disconnected-----", v.name)
	default:
		fmt.Println("unknown decive--------")
	}
}
