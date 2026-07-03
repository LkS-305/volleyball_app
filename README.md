# Vôlei Apoio

Contador de pontos para o **rachão do bairro** — a neighborhood volleyball
scorekeeping app for 2–5 teams. One person keeps score; the app tracks live
points per set, rotates teams in and out between sets, and shows
end-of-session statistics.

## Branches

- **`main`** — the full project: the Flutter app **plus** the Go backend.
- **`lite_version`** — the standalone Flutter app only, with no backend, no
  cloud, and no local persistence.

## Repository layout

```
volei_apoio/          Flutter app (scorekeeper UI + game logic)
volleyball-backend/   Go HTTP service; stores play history in JSON or Google Sheets
```

## Flutter app — `volei_apoio/`

Session state lives in memory (`MatchSession`, a `ChangeNotifier`). There is no
persistence yet: closing the app clears the current session. Requires the
Flutter SDK (3.x).

```bash
cd volei_apoio
flutter pub get
flutter run
```

## Go backend — `volleyball-backend/`

A small `net/http` service that stores the history of play and computes
statistics. It records two things behind one `Store` interface:

- **Games** — one per session (teams, rules, date, standings).
- **Matches** — one per set played within a session, linked by `session_id`.

Two interchangeable backends, picked at start-up via `STORE_BACKEND`:

- `json` — a local `data/sessions.json` file (default, zero setup).
- `sheets` — a **Google Spreadsheet** with `Games` and `Matches` tabs (free;
  service-account auth; tabs + headers auto-created on first run).

```bash
cd volleyball-backend
go mod tidy       # resolve deps + write go.sum (needs internet)
go run .          # JSON backend by default; listens on :8080
```

Endpoints:

| Method | Path              | Description                                 |
| ------ | ----------------- | ------------------------------------------- |
| POST   | `/sessions`       | Persist a finished session + its sets       |
| GET    | `/sessions`       | List sessions (newest first)                |
| GET    | `/sessions/{id}`  | One session with its sets                   |
| GET    | `/matches`        | Every set across all sessions               |
| GET    | `/stats`          | Aggregate stats (per-captain, streaks)      |

See [`volleyball-backend/README.md`](volleyball-backend/README.md) for the full
Google Sheets setup (service account + sharing the spreadsheet).

> The Flutter app does not call this backend yet — `lib/services/api_service.dart`
> is a placeholder. Next step: `POST /sessions` when the scorekeeper closes a
> session (the stats screen).
