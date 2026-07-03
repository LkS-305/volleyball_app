package main

import (
	"encoding/json"
	"fmt"
	"os"
	"sort"
	"sync"
	"time"
)

type Store struct {
	mu      sync.RWMutex
	path    string
	matches []Match
}

func NewStore(path string) (*Store, error) {
	s := &Store{path: path}
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
	if err := json.Unmarshal(data, &s.matches); err != nil {
		return nil, fmt.Errorf("parsing store file: %w", err)
	}
	return s, nil
}

func (s *Store) Add(m Match) (Match, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	m.ID = fmt.Sprintf("m_%d", time.Now().UnixNano())
	s.matches = append(s.matches, m)
	if err := s.saveLocked(); err != nil {
		return Match{}, err
	}
	return m, nil
}

func (s *Store) All() []Match {
	s.mu.RLock()
	defer s.mu.RUnlock()
	out := make([]Match, len(s.matches))
	copy(out, s.matches)
	sort.Slice(out, func(i, j int) bool {
		return out[i].PlayedAt.After(out[j].PlayedAt)
	})
	return out
}

func (s *Store) Get(id string) (Match, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	for _, m := range s.matches {
		if m.ID == id {
			return m, true
		}
	}
	return Match{}, false
}

func (s *Store) saveLocked() error {
	data, err := json.MarshalIndent(s.matches, "", "  ")
	if err != nil {
		return fmt.Errorf("encoding matches: %w", err)
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
