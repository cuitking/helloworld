package main

import (
	"log"
	"net/http"
	"time"
	"os"
	"os/signal"
)

func main() {

	server :=&http.Server{
		Addr:":4000",
		WriteTimeout:4*time.Second,
	}

	quit := make(chan os.Signal)
	signal.Notify(quit, os.Interrupt)

	mux := http.NewServeMux()
	mux.Handle("/",&myHandler{})
	mux.HandleFunc("/bye", sayBye)
	server.Handler = mux

	go func() {
		<-quit
		if err:=server.Close(); err != nil {
			log.Fatal("close server:", err)
		}
	}()

	log.Println(" starting  server... v3")
	err:=server.ListenAndServe()
	if err!=nil {
		if err == http.ErrServerClosed{
			log.Print("server closed under request")
		}else{
			log.Fatal("Server closed unexpected")
		}
	}
	log.Println("server exit success!!!")
	///log.Fatal(server.ListenAndServe())
	// http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
	// 	w.Write([]byte("Hello ,this is version 1!!!"))
	// })

	// http.HandleFunc("/bye", sayBye)
	// log.Println("starting server ... v1")
	// log.Fatal(http.ListenAndServe(":4000", nil))
}

type myHandler struct{}

func (*myHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("hello world  this is version 2!!!!!!! n URL is:" + r.URL.String()))

}
func sayBye(w http.ResponseWriter, r *http.Request) {
	time.Sleep(3*time.Second)
	w.Write([]byte("-------saybyebye -----------  this is version 1"))
}
