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
the allowed fields and types, and denies profile deletion. These rules require
Firebase Authentication; the current app's sign-in form is still a demo and
must be connected to Firebase Auth before real financial data is stored.

To connect this project, run `flutterfire configure` from the Flutter project,
create a Cloud Firestore database in the Firebase Console, then deploy the
rules with `firebase deploy --only firestore:rules`.
