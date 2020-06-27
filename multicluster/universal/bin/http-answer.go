package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
)

func main() {
	if len(os.Args) != 3 {
		println("usage: executable port message")
		os.Exit(1)
	}
	port, err := strconv.Atoi(os.Args[1])
	if err != nil {
		panic("invalid port")
	}
	msg := os.Args[2]
	http.HandleFunc("/", handler(msg))
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", port), nil))
}

func handler(msg string) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		log.Printf("From %s URL: %s. Answer: %s",r.RemoteAddr, r.URL.String(), msg)
		fmt.Fprintf(w, fmt.Sprintf("%s\n", msg))
	}
}
