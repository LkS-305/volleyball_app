package main

import (
	"log"
	"net/http"
	"os"
)

func main() {
	if err := os.MkdirAll("data", 0o755); err != nil {
		log.Fatalf("could not create data directory: %v", err)
	}
	store, err := NewStore("data/matches.json")
	if err != nil {
		log.Fatalf("could not load store: %v", err)
	}
	mux := http.NewServeMux()
	mux.HandleFunc("POST /matches", handleCreateMatch(store))
	mux.HandleFunc("GET /matches", handleListMatches(store))
	mux.HandleFunc("GET /matches/{id}", handleGetMatch(store))
	addr := ":8080"
	log.Printf("volleyball backend listening on %s", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
