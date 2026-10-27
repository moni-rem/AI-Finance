# Finora Java AI backend

This Spring Boot service receives requests from the Flutter app and calls the
Gemini API. The Gemini API key stays in this Java process and is never placed
in the Flutter build.

## Requirements

- Java 17 or newer
- Maven 3.6.3 or newer
- A Gemini API key from Google AI Studio
- Google Cloud CLI for local Firebase Admin credentials and Cloud Run deployment

## Run locally on Windows PowerShell

Install Maven 3.6.3 or newer and the Google Cloud CLI. Sign in and create local
Application Default Credentials for Firebase token verification:

```powershell
gcloud auth application-default login
```

Then start the backend from this directory. The following prompts for the
Gemini key without echoing it or adding it to the PowerShell command history:

```powershell
$secret = Read-Host "Gemini API key" -AsSecureString
$secretPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)
try {
    $env:GEMINI_API_KEY = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($secretPointer)
    $env:FIREBASE_PROJECT_ID = "financeai-1f64e"
    $env:HOST = "0.0.0.0"
    mvn spring-boot:run
} finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($secretPointer)
    Remove-Item Env:GEMINI_API_KEY -ErrorAction SilentlyContinue
    Remove-Item Env:FIREBASE_PROJECT_ID -ErrorAction SilentlyContinue
    Remove-Item Env:HOST -ErrorAction SilentlyContinue
}
```

Keep this terminal running. Verify the backend from the computer at
`http://127.0.0.1:8787/health`.

In a second terminal, run the Flutter app from `finance_analytic`. For the
Android emulator, use its host-machine address `10.0.2.2`:

```powershell
flutter pub get
flutter run --dart-define=AI_BACKEND_URL=http://10.0.2.2:8787
```

For a physical phone, use the computer's LAN IP instead, for example
`http://192.168.1.20:8787`, and allow port 8787 through the computer's private
network firewall. Both devices must be on the same network. The app sends totals, category
totals, budgets, and recent transaction category/amount/date values; it omits
merchant names and notes.

## Deploy to Google Cloud Run

The `/chat` endpoint requires a valid Firebase Authentication ID token. The
Flutter app attaches the token for the currently signed-in user. Guest users
without a Firebase account can keep using the local assistant, but need to
sign in to use the online Gemini assistant.

1. In Google Cloud Console, select or create project `financeai-1f64e`, enable
   billing, and enable Cloud Run, Cloud Build, and Secret Manager APIs. Charges
   may apply.
2. In Secret Manager, create a secret named `gemini-api-key` containing your
   Gemini API key. Do not put this key in Flutter or commit it to Git.
3. Install the Google Cloud CLI, then run `gcloud auth login` and
   `gcloud config set project financeai-1f64e`.
4. From this directory (the one containing `pom.xml`), deploy:

   ```powershell
   gcloud run deploy finora-ai --source . --region asia-southeast1 --set-secrets GEMINI_API_KEY=gemini-api-key:latest --set-env-vars FIREBASE_PROJECT_ID=financeai-1f64e,HOST=0.0.0.0 --allow-unauthenticated
   ```

   Cloud Run's public ingress lets the mobile app reach the service; the Java
   `/chat` handler verifies the Firebase token before using Gemini. If prompted,
   enable APIs and allow public access. The current per-user request limit is
   held in memory and resets when the service restarts; add a shared quota store
   before scaling to multiple instances. Configure quotas and spending alerts
   in Google Cloud.
5. Copy the HTTPS service URL printed after deployment. Check
   `https://YOUR-SERVICE-URL/health` in a browser.
6. From `finance_analytic`, build the release APK with that URL:

   ```powershell
   flutter build apk --release --no-tree-shake-icons --dart-define=AI_BACKEND_URL=https://YOUR-SERVICE-URL
   ```

The release APK is written to
`finance_analytic/build/app/outputs/flutter-apk/app-release.apk`.

The default model is `gemini-3.8-flash`. Override it on the server with
`GEMINI_MODEL` if needed. Configure the server port with `PORT` and network
interface with `HOST`.
