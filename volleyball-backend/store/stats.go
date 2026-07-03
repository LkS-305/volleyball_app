package store

import "sort"

// Stats is an aggregate view computed on demand from stored data.
type Stats struct {
	TotalSessions int           `json:"total_sessions"`
	TotalMatches  int           `json:"total_matches"`
	Captains      []CaptainStat `json:"captains"`
	LongestStreak StreakStat    `json:"longest_streak"`
}

// CaptainStat is one captain's record across all stored sets.
type CaptainStat struct {
	Captain string  `json:"captain"`
	Played  int     `json:"played"`
	Wins    int     `json:"wins"`
	Losses  int     `json:"losses"`
	WinRate float64 `json:"win_rate"`
}

// StreakStat is the longest run of consecutive set wins by any captain.
type StreakStat struct {
	Captain string `json:"captain"`
	Length  int    `json:"length"`
}

// ComputeStats aggregates per-captain records and the longest win streak.
// `matches` may be in any order; the streak is computed chronologically.
func ComputeStats(totalSessions int, matches []Match) Stats {
	st := Stats{TotalSessions: totalSessions, TotalMatches: len(matches)}

	type rec struct{ played, wins int }
	recs := map[string]*rec{}
	get := func(c string) *rec {
		r := recs[c]
		if r == nil {
			r = &rec{}
			recs[c] = r
		}
		return r
	}
	for _, m := range matches {
		get(m.TeamACaptain).played++
		get(m.TeamBCaptain).played++
		get(m.WinnerCaptain).wins++
	}

	for c, r := range recs {
		cs := CaptainStat{Captain: c, Played: r.played, Wins: r.wins, Losses: r.played - r.wins}
		if r.played > 0 {
			cs.WinRate = float64(r.wins) / float64(r.played)
		}
		st.Captains = append(st.Captains, cs)
	}
	sort.Slice(st.Captains, func(i, j int) bool {
		if st.Captains[i].Wins != st.Captains[j].Wins {
			return st.Captains[i].Wins > st.Captains[j].Wins
		}
		return st.Captains[i].Captain < st.Captains[j].Captain
	})

	// Longest win streak, oldest set first. Only the loser resets to 0, so a
	// team that sits out keeps its streak — matching the Flutter app's logic.
	chrono := make([]Match, len(matches))
	copy(chrono, matches)
	sort.Slice(chrono, func(i, j int) bool { return chrono[i].PlayedAt.Before(chrono[j].PlayedAt) })

	streaks := map[string]int{}
	for _, m := range chrono {
		loser := m.TeamACaptain
		if m.WinnerCaptain == m.TeamACaptain {
			loser = m.TeamBCaptain
		}
		streaks[m.WinnerCaptain]++
		streaks[loser] = 0
		if streaks[m.WinnerCaptain] > st.LongestStreak.Length {
			st.LongestStreak = StreakStat{Captain: m.WinnerCaptain, Length: streaks[m.WinnerCaptain]}
		}
	}
	return st
}
