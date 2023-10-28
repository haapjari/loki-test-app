package main

import (
	"log"
	"net/http"
)

func logHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("INFO: Test Log Entry")
}

func main() {
	http.HandleFunc("/", logHandler)
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatalf("unable to start server: %v", err)
	}
}
