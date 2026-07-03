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
volleyball-backend/   Go HTTP service that stores completed matches as JSON
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

A small `net/http` service that validates completed matches and stores them to
`data/matches.json`. Requires Go 1.22+.

```bash
cd volleyball-backend
go run .          # listens on :8080
```

Endpoints:

| Method | Path            | Description                     |
| ------ | --------------- | ------------------------------- |
| POST   | `/matches`      | Create a match                  |
| GET    | `/matches`      | List matches (newest first)     |
| GET    | `/matches/{id}` | Fetch a single match by id      |

> The Flutter app does not call this backend yet — `lib/services/api_service.dart`
> is a placeholder. Planned next: replace the JSON store with a Google Sheets
> backend, then wire the app to it.
