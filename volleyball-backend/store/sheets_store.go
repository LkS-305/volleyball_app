package store

import (
	"context"
	"fmt"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"

	"google.golang.org/api/option"
	"google.golang.org/api/sheets/v4"
)

// Tab names inside the spreadsheet.
const (
	gamesSheet   = "Games"   // one row per session
	matchesSheet = "Matches" // one row per set, linked by session_id
)

var (
	gamesHeader = []interface{}{
		"id", "played_at", "points_per_set", "rotation_rule", "num_teams", "teams", "num_matches",
	}
	matchesHeader = []interface{}{
		"id", "session_id", "played_at", "team_a_captain", "team_b_captain", "pts_a", "pts_b", "winner_captain",
	}
)

// SheetsStore persists sessions and sets to a Google Spreadsheet — the "Games"
// tab for sessions and the "Matches" tab for sets. Authentication is via a
// service-account key; the spreadsheet must be shared (Editor) with the service
// account's email address.
type SheetsStore struct {
	mu            sync.Mutex
	svc           *sheets.Service
	spreadsheetID string
}

// NewSheetsStore builds the client and makes sure both tabs and their headers
// exist, creating them if needed.
func NewSheetsStore(ctx context.Context, credentialsPath, spreadsheetID string) (*SheetsStore, error) {
	if credentialsPath == "" {
		return nil, fmt.Errorf("GOOGLE_SHEETS_CREDENTIALS_PATH is required for the sheets backend")
	}
	if spreadsheetID == "" {
		return nil, fmt.Errorf("GOOGLE_SHEETS_SPREADSHEET_ID is required for the sheets backend")
	}
	svc, err := sheets.NewService(ctx,
		option.WithCredentialsFile(credentialsPath),
		option.WithScopes(sheets.SpreadsheetsScope),
	)
	if err != nil {
		return nil, fmt.Errorf("creating sheets service: %w", err)
	}
	s := &SheetsStore{svc: svc, spreadsheetID: spreadsheetID}
	if err := s.ensureSheets(); err != nil {
		return nil, err
	}
	return s, nil
}

// ensureSheets creates the Games/Matches tabs and writes their header rows if
// they are missing. Safe to run on every start-up.
func (s *SheetsStore) ensureSheets() error {
	ss, err := s.svc.Spreadsheets.Get(s.spreadsheetID).Do()
	if err != nil {
		return fmt.Errorf("reading spreadsheet: %w", err)
	}
	existing := map[string]bool{}
	for _, sh := range ss.Sheets {
		existing[sh.Properties.Title] = true
	}

	var addReqs []*sheets.Request
	for _, title := range []string{gamesSheet, matchesSheet} {
		if !existing[title] {
			addReqs = append(addReqs, &sheets.Request{
				AddSheet: &sheets.AddSheetRequest{
					Properties: &sheets.SheetProperties{Title: title},
				},
			})
		}
	}
	if len(addReqs) > 0 {
		if _, err := s.svc.Spreadsheets.BatchUpdate(s.spreadsheetID,
			&sheets.BatchUpdateSpreadsheetRequest{Requests: addReqs}).Do(); err != nil {
			return fmt.Errorf("creating sheets: %w", err)
		}
	}

	if err := s.ensureHeader(gamesSheet, gamesHeader); err != nil {
		return err
	}
	return s.ensureHeader(matchesSheet, matchesHeader)
}

func (s *SheetsStore) ensureHeader(sheet string, header []interface{}) error {
	resp, err := s.svc.Spreadsheets.Values.Get(s.spreadsheetID, sheet+"!1:1").Do()
	if err != nil {
		return fmt.Errorf("reading %s header: %w", sheet, err)
	}
	if len(resp.Values) > 0 && len(resp.Values[0]) > 0 {
		return nil // header already present
	}
	if _, err := s.svc.Spreadsheets.Values.Update(s.spreadsheetID, sheet+"!A1",
		&sheets.ValueRange{Values: [][]interface{}{header}}).
		ValueInputOption("RAW").Do(); err != nil {
		return fmt.Errorf("writing %s header: %w", sheet, err)
	}
	return nil
}

func (s *SheetsStore) AddSession(req NewSessionRequest) (Session, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	sess := buildSession(req, time.Now().UTC())

	gameRow := []interface{}{
		sess.ID,
		sess.PlayedAt.Format(time.RFC3339),
		sess.PointsPerSet,
		sess.RotationRule,
		len(sess.Teams),
		formatTeams(sess.Teams),
		sess.NumMatches,
	}
	if _, err := s.svc.Spreadsheets.Values.Append(s.spreadsheetID, gamesSheet+"!A1",
		&sheets.ValueRange{Values: [][]interface{}{gameRow}}).
		ValueInputOption("RAW").InsertDataOption("INSERT_ROWS").Do(); err != nil {
		return Session{}, fmt.Errorf("appending game row: %w", err)
	}

	var matchRows [][]interface{}
	for _, m := range sess.Matches {
		matchRows = append(matchRows, []interface{}{
			m.ID, m.SessionID, m.PlayedAt.Format(time.RFC3339),
			m.TeamACaptain, m.TeamBCaptain, m.PtsA, m.PtsB, m.WinnerCaptain,
		})
	}
	if len(matchRows) > 0 {
		if _, err := s.svc.Spreadsheets.Values.Append(s.spreadsheetID, matchesSheet+"!A1",
			&sheets.ValueRange{Values: matchRows}).
			ValueInputOption("RAW").InsertDataOption("INSERT_ROWS").Do(); err != nil {
			return Session{}, fmt.Errorf("appending match rows: %w", err)
		}
	}
	return sess, nil
}

func (s *SheetsStore) Sessions() ([]Session, error) {
	resp, err := s.svc.Spreadsheets.Values.Get(s.spreadsheetID, gamesSheet+"!A2:G").Do()
	if err != nil {
		return nil, fmt.Errorf("reading games: %w", err)
	}
	out := make([]Session, 0, len(resp.Values))
	for _, row := range resp.Values {
		out = append(out, parseGameRow(row))
	}
	sort.Slice(out, func(i, j int) bool { return out[i].PlayedAt.After(out[j].PlayedAt) })
	return out, nil
}

func (s *SheetsStore) Matches() ([]Match, error) {
	resp, err := s.svc.Spreadsheets.Values.Get(s.spreadsheetID, matchesSheet+"!A2:H").Do()
	if err != nil {
		return nil, fmt.Errorf("reading matches: %w", err)
	}
	out := make([]Match, 0, len(resp.Values))
	for _, row := range resp.Values {
		out = append(out, parseMatchRow(row))
	}
	sort.Slice(out, func(i, j int) bool { return out[i].PlayedAt.After(out[j].PlayedAt) })
	return out, nil
}

// --- row (de)serialization helpers ---------------------------------------

func formatTeams(teams []TeamResult) string {
	parts := make([]string, 0, len(teams))
	for _, t := range teams {
		parts = append(parts, fmt.Sprintf("%s (%d)", t.Captain, t.NumWins))
	}
	return strings.Join(parts, ", ")
}

func parseGameRow(row []interface{}) Session {
	return Session{
		ID:           cell(row, 0),
		PlayedAt:     parseTime(cell(row, 1)),
		PointsPerSet: atoi(cell(row, 2)),
		RotationRule: cell(row, 3),
		NumMatches:   atoi(cell(row, 6)),
	}
}

func parseMatchRow(row []interface{}) Match {
	return Match{
		ID:            cell(row, 0),
		SessionID:     cell(row, 1),
		PlayedAt:      parseTime(cell(row, 2)),
		TeamACaptain:  cell(row, 3),
		TeamBCaptain:  cell(row, 4),
		PtsA:          atoi(cell(row, 5)),
		PtsB:          atoi(cell(row, 6)),
		WinnerCaptain: cell(row, 7),
	}
}

func cell(row []interface{}, i int) string {
	if i < len(row) && row[i] != nil {
		return fmt.Sprintf("%v", row[i])
	}
	return ""
}

func atoi(s string) int {
	n, _ := strconv.Atoi(strings.TrimSpace(s))
	return n
}

func parseTime(s string) time.Time {
	t, err := time.Parse(time.RFC3339, strings.TrimSpace(s))
	if err != nil {
		return time.Time{}
	}
	return t
}
