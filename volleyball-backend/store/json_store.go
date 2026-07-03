package store

import (
	"encoding/json"
	"fmt"
	"os"
	"sort"
	"sync"
	"time"
)

// JSONStore persists sessions (with their matches embedded) to a local JSON
// file. It is the zero-setup fallback and the default for local development.
type JSONStore struct {
	mu       sync.RWMutex
	path     string
	sessions []Session
}

// NewJSONStore loads an existing file if present, or starts empty.
func NewJSONStore(path string) (*JSONStore, error) {
	s := &JSONStore{path: path}
	data, err := os.ReadFile(path)
	if os.IsNotExist(err) {
		return s, nil
	}
	if err != nil {
		return nil, fmt.Errorf("reading store file: %w", err)
	}
	if len(data) == 0 {
		return s, nil
	}
	if err := json.Unmarshal(data, &s.sessions); err != nil {
		return nil, fmt.Errorf("parsing store file: %w", err)
	}
	return s, nil
}

func (s *JSONStore) AddSession(req NewSessionRequest) (Session, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	sess := buildSession(req, time.Now().UTC())
	s.sessions = append(s.sessions, sess)
	if err := s.saveLocked(); err != nil {
		return Session{}, err
	}
	return sess, nil
}

func (s *JSONStore) Sessions() ([]Session, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	out := make([]Session, 0, len(s.sessions))
	for _, sess := range s.sessions {
		meta := sess
		meta.Matches = nil // list endpoint returns metadata only
		out = append(out, meta)
	}
	sort.Slice(out, func(i, j int) bool { return out[i].PlayedAt.After(out[j].PlayedAt) })
	return out, nil
}

func (s *JSONStore) Matches() ([]Match, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	var out []Match
	for _, sess := range s.sessions {
		out = append(out, sess.Matches...)
	}
	sort.Slice(out, func(i, j int) bool { return out[i].PlayedAt.After(out[j].PlayedAt) })
	return out, nil
}

// saveLocked writes atomically via a temp file + rename. Caller holds the lock.
func (s *JSONStore) saveLocked() error {
	data, err := json.MarshalIndent(s.sessions, "", "  ")
	if err != nil {
		return fmt.Errorf("encoding sessions: %w", err)
	}
	tmp := s.path + ".tmp"
	if err := os.WriteFile(tmp, data, 0o644); err != nil {
		return fmt.Errorf("writing temp file: %w", err)
	}
	if err := os.Rename(tmp, s.path); err != nil {
		return fmt.Errorf("renaming temp file: %w", err)
	}
	return nil
}
