# Firestore database layout

The app's financial data should be stored under the authenticated user's UID:

```text
users/{uid}
  displayName: string
  email: string
  createdAt: timestamp
  updatedAt: timestamp

users/{uid}/transactions/{transactionId}
  name: string
  category: string
  date: string
  amount: number       # positive income, negative expense
  iconCode: integer
  colorValue: integer
  note: string
  createdAt: timestamp

users/{uid}/budgets/{budgetId}
  title: string
  spent: number
  limit: number
  iconCode: integer
  colorValue: integer

users/{uid}/goals/{goalId}
  title: string
  saved: number
  target: number
  iconCode: integer
  colorValue: integer
```

`firestore.rules` restricts each user to their own profile and data, validates
the allowed fields and types, and permits users to delete their own profile.
The profile's Delete Account action removes the user's transactions, budgets,
goals, profile document, Firebase Authentication account, and local PIN. The app uses Firebase
email/password authentication and stores signed-in users' transactions and
budgets under their own UID. New transactions and budgets load again on sign-in.

## Firebase setup

Firebase project configuration is not included in this repository. From the
Flutter project directory, sign in to Firebase, install the FlutterFire CLI,
and configure the Android and iOS apps:

```powershell
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --platforms android,ios
firebase use --add
```

In Firebase Console, enable **Authentication > Email/Password** and create a
Cloud Firestore database. Then deploy the existing security rules:

```powershell
firebase deploy --only firestore:rules
```

For web, pass the Firebase web app values when running/building Flutter using
`FIREBASE_API_KEY`, `FIREBASE_WEB_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, and
`FIREBASE_PROJECT_ID` dart defines. `FIREBASE_AUTH_DOMAIN` and
`FIREBASE_STORAGE_BUCKET` are optional. The Java backend remains the AI chat
proxy; budget data is stored directly in Firestore.
