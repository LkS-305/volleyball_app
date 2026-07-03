package main

import (
	"encoding/json"
	"log"
	"net/http"
)

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(v); err != nil {
		log.Printf("error encoding response: %v", err)
	}
}

func writeError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, map[string]string{"error": message})
}

func handleCreateMatch(store *Store) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req NewMatchRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			writeError(w, http.StatusBadRequest, "invalid JSON body")
			return
		}
		if err := req.Validate(); err != nil {
			writeError(w, http.StatusUnprocessableEntity, err.Error())
			return
		}
		saved, err := store.Add(req.ToMatch())
		if err != nil {
			log.Printf("error saving match: %v", err)
			writeError(w, http.StatusInternalServerError, "could not save match")
			return
		}
		writeJSON(w, http.StatusCreated, saved)
	}
}

func handleListMatches(store *Store) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, store.All())
	}
}

func handleGetMatch(store *Store) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		match, ok := store.Get(id)
		if !ok {
			writeError(w, http.StatusNotFound, "match not found")
			return
		}
		writeJSON(w, http.StatusOK, match)
	}
}
