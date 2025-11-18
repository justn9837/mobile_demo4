# Stress / Mood Tracker & Daily Journal (GetX + Supabase + Hive + SharedPreferences)

This project scaffold implements the requested structure and basic functionality.

Important setup

1. Copy `.env.example` to `.env` at project root and fill:

```
SUPABASE_URL=https://qnxjzuqtiemqnwghanup.supabase.co
SUPABASE_ANON_KEY=YOUR_ANON_KEY_HERE
```

2. Do NOT commit `.env`.

3. Run:

```powershell
flutter pub get
flutter run
```

Features implemented (scaffold):
- GetX app structure with routes and controllers.
- Supabase service wrapper and basic AuthService registering a profile row.
- StorageService skeleton to upload avatar to `foto_profil` bucket.
- Hive models for `UserModel` and `JournalEntry` and local storage for entries.
- Daily Journal view with offline-first saving to Hive and a sync method.
- Benchmark page measuring shared_preferences, Hive and HTTP request times.
- `.env.example` and `sql/policies.sql` included.

Notes for implementor

- Run `flutter pub get` to fetch dependencies before running.
- Generate Hive adapters using build_runner if you want typed adapters:

```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

- The Supabase project details in the request should be added to `.env`.

- SQL policies file contains example RLS policies intended to be adapted to your Supabase schema.

- Affirmations API (`https://www.affirmations.dev/`) is used in Benchmark as a simple remote call.

Acceptance checklist (manual):
- Register should create Supabase Auth user and profiles row.
- Login via email should fetch role from `profiles` and navigate to the appropriate home.
- Entries saved offline should appear in Hive and be synced with `syncPending()` when online.

If you want, I can now:
- Run `flutter doctor -v` here and report environment issues.
- Run `flutter pub get` and try `flutter run` to validate compilation (requires device/emulator).
- Flesh out UI to exactly match your `mobile_demo` repo (I need that repo or screenshots to match exactly).
