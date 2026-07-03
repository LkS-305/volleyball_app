# Vôlei Apoio — Lite

Contador de pontos para o **rachão do bairro** — a self-contained neighborhood
volleyball scorekeeping app for 2–5 teams. One person keeps score; the app
tracks live points per set, rotates teams in and out between sets, and shows
end-of-session statistics.

> **This is the lite version.** It is a pure Flutter app with **no backend, no
> cloud, and no local persistence**. The whole session lives in memory —
> closing the app clears it. For the version that also includes the Go backend,
> see the [`main`](../../tree/main) branch.

## Run

Requires the Flutter SDK (3.x).

```bash
cd volei_apoio
flutter pub get
flutter run
```

## Structure

```
volei_apoio/lib/
├── main.dart                     app entry point
├── theme/team_colors.dart        fixed team color palette
├── models/                       Team, Match, Game domain models
├── state/match_session.dart      in-memory session state (ChangeNotifier)
├── screens/                      the app screens (intro → rules → captains →
│                                 scoring → winner → stats, plus settings)
└── widgets/                      shared UI components
```

There is no `services/` layer and no network code — nothing leaves the device.
