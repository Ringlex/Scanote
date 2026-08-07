# Scanote

An Android notebook where **a photograph of text becomes a note you can search for**. The
camera is the way in — the floating button takes a picture, and writing by hand lives under
the pencil in the bar.

Text recognition runs **on the device** (ML Kit, with the model bundled into the app), so the
photograph never leaves the phone. That is the argument against Google Lens, and it belongs in
the first sentences of the store listing.

## Features

- **Multi-page scanning** — one photograph after another lands in a single note
- **List detection** — a scanned shopping list arrives as a checklist, not a block of text
- **Protected notes** — AES-256-GCM with a key in the Android Keystore, opened with a
  fingerprint or the screen lock
- **Backup to Google Drive** — protected notes are re-encrypted under a separate backup
  passphrase
- **Calendar with reminders**, categories, favourites, a bin with a 30-day retention
- **Dictation**, sharing by QR code, a home screen widget, `ACTION_SEND` support
- Polish and English

## Running it

The project uses [FVM](https://fvm.app). The Flutter version is pinned in `.fvmrc` (**3.41.0**).

```bash
fvm install
fvm flutter pub get
fvm flutter run
```

Everything except the backup works without signing in to Google — choose
**"Continue without an account"**.

## Google setup (only needed for the backup)

This is where hours go missing, so it is spelled out. **Two different OAuth clients** are
involved, and confusing them is the usual mistake.

| Client | What it does | Does it appear in the code |
|---|---|---|
| **Android** | identifies the app by package name and signing SHA-1 | **no** |
| **Web** | lets the app ask Google for a token of identity | **yes**, as `serverClientId` |

1. In the Google Cloud Console, enable the **Google Drive API**
2. Create an **Android OAuth client**: package `io.robert.note`, and the SHA-1 of the key you
   sign the build with
3. Create a **Web OAuth client** — the redirect URI fields can be left empty
4. Put the Web client id into `lib/core/constants/google_auth_const.dart`
5. On the **consent screen**, add your own account as a test user

The debug key's fingerprint comes out of:

```bash
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

> **Without `serverClientId`, signing in says nothing at all.** No error, no account picker —
> the button simply does nothing. The real reason (`clientConfigurationError`) shows up only in
> logcat, on the `SIGNIN_DIAGNOSTIC` line, and only in a debug build.

## Everyday commands

```bash
fvm flutter analyze
fvm flutter test
fvm flutter gen-l10n                  # after every change to assets/l10n/*.arb
fvm dart run build_runner build       # after changing freezed models or bloc events
fvm flutter build apk --release
```

The strings live in `assets/l10n/translations_pl.arb` and `translations_en.arb`, and the
`Translations` class is generated from them into `lib/core/l10n/`. The generated files are
committed, so a fresh clone builds — but **after every change to an `.arb` file, run `gen-l10n`
and commit the result**, or the code will reach for keys the generated class does not know yet.

## Worth knowing before you change things

### The ciphertext carries a version byte, and it has to

`NoteCipher` writes a **format version byte** at the front of every ciphertext. This is not
decoration: without it two different encryption schemes produce bytes of the same length and
the same shape, and the only symptom of using the wrong one is a MAC failure — indistinguishable
from a lost key, and with no way to migrate.

**If you change the encryption format, bump that byte and write a migration path.** Otherwise
an app update takes people's notes away for good.

### The encryption is enveloped

The Keystore key does not encrypt notes. It encrypts a **data key**, and that key encrypts the
contents. One authentication therefore unlocks any number of notes, which is what makes an
export possible without a fingerprint prompt per note.

### The database has migrations

`_databaseVersion` in `db_helper.dart` is **7**. Every schema change is a new
`if (oldVersion < N)` block in `_onUpgrade` — never a rebuilt table, because the user's notes
are in it.

### What protecting a note does not cover

The title stays in the clear, so the note can still be found. Only text notes can be protected,
not checklists. In the widget, a protected note shows as 🔒.

## Before release

- [ ] A **keystore** for signing, and its **SHA-1** registered on the Android OAuth client
- [ ] With **Play App Signing**, register the fingerprint Google signs with as well
- [ ] Move the **consent screen** to production — in testing mode tokens expire after 7 days
- [ ] App name on the consent screen: **Scanote** (it tends to keep the old one)
- [ ] Publish the [privacy policy](docs/privacy-policy.md) and
      [terms](docs/terms-of-service.md) at public URLs and enter them in the console
- [ ] Fill in the bracketed placeholders in both documents
- [ ] Screenshots and a store description
- [ ] Check the name "Scanote" in Google Play and at EUIPO

## Tests

Seven test files, including full cover of `NoteCipher` — encryption, the version byte,
detecting tampered text, and deriving a key from a passphrase — and of search matching.

```bash
fvm flutter test
```

The tests do not reach the native side: `BiometricPrompt`, the Keystore, the widget and
`ACTION_SEND` are checked on a device or not at all.
