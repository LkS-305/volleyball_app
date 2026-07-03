package store

// Store is the persistence boundary for the backend. Implementations:
//   - JSONStore   — a local JSON file (zero setup, good for dev).
//   - SheetsStore — a Google Spreadsheet ("Games" + "Matches" tabs).
//
// main.go selects one at startup based on the STORE_BACKEND env var.
type Store interface {
	// AddSession persists a finished session and its sets, assigning ids, and
	// returns the stored Session (with its Matches populated).
	AddSession(req NewSessionRequest) (Session, error)

	// Sessions returns every stored session as metadata (no Matches), newest
	// first. Use Matches to read the individual sets.
	Sessions() ([]Session, error)

	// Matches returns every stored set across all sessions, newest first.
	Matches() ([]Match, error)
}
