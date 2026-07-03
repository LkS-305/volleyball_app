package main

import (
	"errors"
	"time"
)

type SetScore struct {
	TeamAPoints int `json:"team_a_points"`
	TeamBPoints int `json:"team_b_points"`
}

type Match struct {
	ID           string     `json:"id"`
	TeamAName    string     `json:"team_a_name"`
	TeamACaptain string     `json:"team_a_captain"`
	TeamBName    string     `json:"team_b_name"`
	TeamBCaptain string     `json:"team_b_captain"`
	PointsPerSet int        `json:"points_per_set"`
	Sets         []SetScore `json:"sets"`
	SetsWonA     int        `json:"sets_won_a"`
	SetsWonB     int        `json:"sets_won_b"`
	Winner       string     `json:"winner"`
	PlayedAt     time.Time  `json:"played_at"`
}

type NewMatchRequest struct {
	TeamAName    string     `json:"team_a_name"`
	TeamACaptain string     `json:"team_a_captain"`
	TeamBName    string     `json:"team_b_name"`
	TeamBCaptain string     `json:"team_b_captain"`
	PointsPerSet int        `json:"points_per_set"`
	Sets         []SetScore `json:"sets"`
	Winner       string     `json:"winner"`
}

func (r *NewMatchRequest) Validate() error {
	if r.TeamAName == "" || r.TeamBName == "" {
		return errors.New("team_a_name and team_b_name are required")
	}
	if r.PointsPerSet != 15 && r.PointsPerSet != 25 {
		return errors.New("points_per_set must be 15 or 25")
	}
	if len(r.Sets) == 0 {
		return errors.New("sets must contain at least one set")
	}
	if r.Winner != "team_a" && r.Winner != "team_b" {
		return errors.New("winner must be \"team_a\" or \"team_b\"")
	}
	setsWonA, setsWonB := 0, 0
	for _, s := range r.Sets {
		if s.TeamAPoints < 0 || s.TeamBPoints < 0 {
			return errors.New("set points cannot be negative")
		}
		if s.TeamAPoints == s.TeamBPoints {
			return errors.New("a set cannot end in a tie")
		}
		if s.TeamAPoints > s.TeamBPoints {
			setsWonA++
		} else {
			setsWonB++
		}
	}
	if r.Winner == "team_a" && setsWonA <= setsWonB {
		return errors.New("winner is team_a but team_a did not win more sets")
	}
	if r.Winner == "team_b" && setsWonB <= setsWonA {
		return errors.New("winner is team_b but team_b did not win more sets")
	}
	return nil
}

func (r *NewMatchRequest) ToMatch() Match {
	setsWonA, setsWonB := 0, 0
	for _, s := range r.Sets {
		if s.TeamAPoints > s.TeamBPoints {
			setsWonA++
		} else {
			setsWonB++
		}
	}
	return Match{
		TeamAName:    r.TeamAName,
		TeamACaptain: r.TeamACaptain,
		TeamBName:    r.TeamBName,
		TeamBCaptain: r.TeamBCaptain,
		PointsPerSet: r.PointsPerSet,
		Sets:         r.Sets,
		SetsWonA:     setsWonA,
		SetsWonB:     setsWonB,
		Winner:       r.Winner,
		PlayedAt:     time.Now().UTC(),
	}
}
