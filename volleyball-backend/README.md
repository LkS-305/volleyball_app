# Vôlei Apoio — backend

A small Go (`net/http`) service that stores the history of play and computes
statistics. It persists two record types:

- **Games** — one per **session** (a "jogo": the teams, rules, date, standings).
- **Matches** — one per **set** (a "partida") played within a session, linked to
  its game by `session_id`.

Two interchangeable storage backends sit behind a single `Store` interface,
chosen at start-up by the `STORE_BACKEND` env var:

| Backend  | Where data goes                    | Setup        |
| -------- | ---------------------------------- | ------------ |
| `json`   | local `data/sessions.json`         | none         |
| `sheets` | a Google Spreadsheet (Games/Matches tabs) | service account |

## Layout

```
volleyball-backend/
├── main.go              wiring + backend selection
├── handlers.go          HTTP handlers
├── config/config.go     env-var config
├── store/
│   ├── store.go         the Store interface
│   ├── models.go        Session / Match / requests + validation
│   ├── json_store.go    local JSON file backend
│   ├── sheets_store.go  Google Sheets backend
│   └── stats.go         on-demand statistics
└── .env.example
```

## Run locally (JSON, zero setup)

```bash
cd volleyball-backend
go mod tidy            # resolves deps and writes go.sum (needs internet)
go run .               # STORE_BACKEND defaults to "json"; listens on :8080
```

## Run against Google Sheets

The Sheets API and a service account are **free**. One-time setup:

1. **Create the spreadsheet.** In Google Sheets, make a blank spreadsheet. Copy
   its id from the URL: `https://docs.google.com/spreadsheets/d/<ID>/edit`.
   (The `Games` and `Matches` tabs + headers are created automatically on first
   run — you don't have to make them.)
2. **Enable the API + create a service account.**
   - Go to <https://console.cloud.google.com/>, create/select a project.
   - Enable **Google Sheets API** (APIs & Services → Library).
   - APIs & Services → Credentials → **Create credentials → Service account**.
   - Open the new service account → **Keys → Add key → JSON**. Download it and
     save it as `volleyball-backend/service-account.json` (gitignored).
3. **Share the sheet with the service account.** Copy the service account's
   email (looks like `name@project.iam.gserviceaccount.com`) and share the
   spreadsheet with it as **Editor**. This is the step people forget — without
   it every call returns `403`.
4. **Configure and run:**

```bash
cp .env.example .env
# edit .env:
#   STORE_BACKEND=sheets
#   GOOGLE_SHEETS_CREDENTIALS_PATH=./service-account.json
#   GOOGLE_SHEETS_SPREADSHEET_ID=<ID from step 1>
set -a; . ./.env; set +a      # load env (bash/git-bash)
go run .
```

On Windows PowerShell, set the vars instead of sourcing `.env`:

```powershell
$env:STORE_BACKEND="sheets"
$env:GOOGLE_SHEETS_CREDENTIALS_PATH="./service-account.json"
$env:GOOGLE_SHEETS_SPREADSHEET_ID="<ID>"
go run .
```

## API

| Method | Path              | Description                                   |
| ------ | ----------------- | --------------------------------------------- |
| POST   | `/sessions`       | Persist a finished session + its sets         |
| GET    | `/sessions`       | List sessions (metadata), newest first        |
| GET    | `/sessions/{id}`  | One session with its sets attached            |
| GET    | `/matches`        | Every set across all sessions, newest first   |
| GET    | `/stats`          | Aggregate stats computed from stored data     |

The app is meant to call `POST /sessions` once, when the scorekeeper closes the
session (the stats screen). Example body:

```json
{
  "points_per_set": 25,
  "rotation_rule": "winner_stays",
  "teams": [
    { "captain": "Ana",   "num_wins": 3 },
    { "captain": "Bruno", "num_wins": 1 }
  ],
  "matches": [
    { "team_a_captain": "Ana", "team_b_captain": "Bruno",
      "pts_a": 25, "pts_b": 18, "winner_captain": "Ana" }
  ]
}
```

`GET /stats` returns totals, a per-captain win/loss table, and the longest
consecutive win streak — computed live from the Matches records, so it always
reflects the current spreadsheet.

> The Flutter app does not call this backend yet — `lib/services/api_service.dart`
> is still a placeholder. Wiring it to `POST /sessions` on session close is the
> next step.
