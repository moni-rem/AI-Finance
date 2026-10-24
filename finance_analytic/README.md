# Finora

A Flutter finance dashboard prototype with transaction, budget, savings goal,
analytics, and AI money coach screens.

## Run the app

```sh
flutter pub get
flutter run
```

Without an AI backend URL, the Money Coach uses its local demo responses.

## Connect the Java Fireworks backend

The Java backend is in the sibling folder `../finance_java_backend`. Start it
there first, following that folder's README. The Fireworks API key belongs in
the Java server environment; never put it in Flutter or pass it with
`--dart-define`.

Then, from this Flutter project, run:

```powershell
flutter run --dart-define=AI_BACKEND_URL=http://127.0.0.1:8787
```

For a phone, web deployment, or production use, configure an HTTPS backend URL.
Add real user authentication and request quotas before exposing the proxy
publicly. The app sends financial totals, category totals, budget limits, and
recent transaction category/amount/date values; it omits merchant names and
notes.

## Tests

```sh
flutter test
```
