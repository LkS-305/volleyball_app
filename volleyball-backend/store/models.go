package store

import (
	"errors"
	"fmt"
	"strings"
	"time"
)

// Rotation rules, mirroring the Flutter RotationRule enum.
const (
	RuleWinnerStays   = "winner_stays"
	RuleTwoMatchesOut = "two_matches_out"
)

// TeamResult is a captain and how many sets their team won during a session.
type TeamResult struct {
	Captain string `json:"captain"`
	NumWins int    `json:"num_wins"`
}

// Match is a single set ("partida") between two teams, belonging to a session.
// It is the atomic unit statistics are computed from.
type Match struct {
	ID            string    `json:"id"`
	SessionID     string    `json:"session_id"`
	TeamACaptain  string    `json:"team_a_captain"`
	TeamBCaptain  string    `json:"team_b_captain"`
	PtsA          int       `json:"pts_a"`
	PtsB          int       `json:"pts_b"`
	WinnerCaptain string    `json:"winner_captain"`
	PlayedAt      time.Time `json:"played_at"`
}

// Session is one sitting of play ("jogo"): a group of teams playing a series of
// sets under one set of rules. It is persisted when the scorekeeper closes the
// session. On write it carries its Matches; on list reads only the metadata is
// returned (Matches is populated by the single-session endpoint).
type Session struct {
	ID           string       `json:"id"`
	PlayedAt     time.Time    `json:"played_at"`
	PointsPerSet int          `json:"points_per_set"`
	RotationRule string       `json:"rotation_rule"`
	Teams        []TeamResult `json:"teams,omitempty"`
	NumMatches   int          `json:"num_matches"`
	Matches      []Match      `json:"matches,omitempty"`
}

// NewSessionRequest is the payload the app POSTs when a session ends.
type NewSessionRequest struct {
	PointsPerSet int          `json:"points_per_set"`
	RotationRule string       `json:"rotation_rule"`
	Teams        []TeamResult `json:"teams"`
	Matches      []NewMatch   `json:"matches"`
}

// NewMatch is a set inside a NewSessionRequest. Ids are assigned server-side.
type NewMatch struct {
	TeamACaptain  string `json:"team_a_captain"`
	TeamBCaptain  string `json:"team_b_captain"`
	PtsA          int    `json:"pts_a"`
	PtsB          int    `json:"pts_b"`
	WinnerCaptain string `json:"winner_captain"`
}

// Validate checks a session payload before it is stored.
func (r *NewSessionRequest) Validate() error {
	if r.PointsPerSet != 15 && r.PointsPerSet != 25 {
		return errors.New("points_per_set must be 15 or 25")
	}
	if r.RotationRule != RuleWinnerStays && r.RotationRule != RuleTwoMatchesOut {
		return errors.New(`rotation_rule must be "winner_stays" or "two_matches_out"`)
	}
	if len(r.Teams) < 2 {
		return errors.New("a session needs at least 2 teams")
	}
	for _, t := range r.Teams {
		if strings.TrimSpace(t.Captain) == "" {
			return errors.New("every team needs a captain name")
		}
		if t.NumWins < 0 {
			return errors.New("num_wins cannot be negative")
		}
	}
	if len(r.Matches) == 0 {
		return errors.New("a session must contain at least one match")
	}
	for i, m := range r.Matches {
		if strings.TrimSpace(m.TeamACaptain) == "" || strings.TrimSpace(m.TeamBCaptain) == "" {
			return fmt.Errorf("match %d: both team captains are required", i)
		}
		if m.TeamACaptain == m.TeamBCaptain {
			return fmt.Errorf("match %d: a team cannot play itself", i)
		}
		if m.PtsA < 0 || m.PtsB < 0 {
			return fmt.Errorf("match %d: points cannot be negative", i)
		}
		if m.WinnerCaptain != m.TeamACaptain && m.WinnerCaptain != m.TeamBCaptain {
			return fmt.Errorf("match %d: winner must be one of the two captains", i)
		}
	}
	return nil
}

// buildSession turns a validated request into a stored Session, assigning a
// session id and per-match ids/timestamps. Matches are spaced 1ms apart so a
// chronological sort is stable even within a single session.
func buildSession(req NewSessionRequest, now time.Time) Session {
	id := fmt.Sprintf("g_%d", now.UnixNano())
	sess := Session{
		ID:           id,
		PlayedAt:     now,
		PointsPerSet: req.PointsPerSet,
		RotationRule: req.RotationRule,
		Teams:        req.Teams,
		NumMatches:   len(req.Matches),
	}
	for i, m := range req.Matches {
		sess.Matches = append(sess.Matches, Match{
			ID:            fmt.Sprintf("m_%d_%d", now.UnixNano(), i),
			SessionID:     id,
			TeamACaptain:  m.TeamACaptain,
			TeamBCaptain:  m.TeamBCaptain,
			PtsA:          m.PtsA,
			PtsB:          m.PtsB,
			WinnerCaptain: m.WinnerCaptain,
			PlayedAt:      now.Add(time.Duration(i) * time.Millisecond),
		})
	}
	return sess
}
