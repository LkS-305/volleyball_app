package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"

	"volleyapi/config"
	"volleyapi/store"
)

func main() {
	cfg := config.Load()

	st, err := buildStore(cfg)
	if err != nil {
		log.Fatalf("could not initialise store: %v", err)
	}

	mux := http.NewServeMux()
	mux.HandleFunc("POST /sessions", handleCreateSession(st))
	mux.HandleFunc("GET /sessions", handleListSessions(st))
	mux.HandleFunc("GET /sessions/{id}", handleGetSession(st))
	mux.HandleFunc("GET /matches", handleListMatches(st))
	mux.HandleFunc("GET /stats", handleStats(st))

	addr := ":" + cfg.Port
	log.Printf("volleyball backend (%s store) listening on %s", cfg.StoreBackend, addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatalf("server error: %v", err)
	}
}

// buildStore picks a Store implementation based on STORE_BACKEND.
func buildStore(cfg config.Config) (store.Store, error) {
	switch cfg.StoreBackend {
	case "sheets":
		return store.NewSheetsStore(context.Background(), cfg.SheetsCredentials, cfg.SpreadsheetID)
	case "json", "":
		if dir := filepath.Dir(cfg.JSONPath); dir != "." && dir != "" {
			if err := os.MkdirAll(dir, 0o755); err != nil {
				return nil, fmt.Errorf("creating data directory: %w", err)
			}
		}
		return store.NewJSONStore(cfg.JSONPath)
	default:
		return nil, fmt.Errorf("unknown STORE_BACKEND %q (want \"json\" or \"sheets\")", cfg.StoreBackend)
	}
}
