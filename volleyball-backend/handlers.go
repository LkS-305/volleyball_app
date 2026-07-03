package main

import (
	"encoding/json"
	"log"
	"net/http"

	"volleyapi/store"
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

// POST /sessions — persist a finished session and its sets.
func handleCreateSession(st store.Store) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req store.NewSessionRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			writeError(w, http.StatusBadRequest, "invalid JSON body")
			return
		}
		if err := req.Validate(); err != nil {
			writeError(w, http.StatusUnprocessableEntity, err.Error())
			return
		}
		saved, err := st.AddSession(req)
		if err != nil {
			log.Printf("error saving session: %v", err)
			writeError(w, http.StatusInternalServerError, "could not save session")
			return
		}
		writeJSON(w, http.StatusCreated, saved)
	}
}

// GET /sessions — list every session (metadata only), newest first.
func handleListSessions(st store.Store) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		sessions, err := st.Sessions()
		if err != nil {
			log.Printf("error listing sessions: %v", err)
			writeError(w, http.StatusInternalServerError, "could not read sessions")
			return
		}
		writeJSON(w, http.StatusOK, sessions)
	}
}

// GET /sessions/{id} — one session with its sets attached.
func handleGetSession(st store.Store) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		sessions, err := st.Sessions()
		if err != nil {
			writeError(w, http.StatusInternalServerError, "could not read sessions")
			return
		}
		var found *store.Session
		for i := range sessions {
			if sessions[i].ID == id {
				found = &sessions[i]
				break
			}
		}
		if found == nil {
			writeError(w, http.StatusNotFound, "session not found")
			return
		}
		matches, err := st.Matches()
		if err != nil {
			writeError(w, http.StatusInternalServerError, "could not read matches")
			return
		}
		for _, m := range matches {
			if m.SessionID == id {
				found.Matches = append(found.Matches, m)
			}
		}
		writeJSON(w, http.StatusOK, found)
	}
}

// GET /matches — every set across all sessions, newest first.
func handleListMatches(st store.Store) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		matches, err := st.Matches()
		if err != nil {
			writeError(w, http.StatusInternalServerError, "could not read matches")
			return
		}
		writeJSON(w, http.StatusOK, matches)
	}
}

// GET /stats — aggregate statistics computed on demand from the stored data.
func handleStats(st store.Store) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		sessions, err := st.Sessions()
		if err != nil {
			writeError(w, http.StatusInternalServerError, "could not read sessions")
			return
		}
		matches, err := st.Matches()
		if err != nil {
			writeError(w, http.StatusInternalServerError, "could not read matches")
			return
		}
		writeJSON(w, http.StatusOK, store.ComputeStats(len(sessions), matches))
	}
}
