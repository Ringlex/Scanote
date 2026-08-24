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
- **The scan is kept** — the photograph stays with the note, so the original settles what
  the recogniser got wrong
- **Formatting that renders** — the toolbar's markers are read back in the note view
- **Protected notes** — AES-256-GCM with a key in the Android Keystore, opened with a
  fingerprint or the screen lock
- **Backup to Google Drive** — protected notes are re-encrypted under a separate backup
  passphrase
- **Sync across devices** (opt-in) — one file on the user's Drive, merged by uuid with the
  later change winning; protected notes and scans stay on the phone
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

Everything except the backup and sync works without signing in to Google — choose
**"Continue without an account"**.

## Google setup (only needed for the backup and sync)

This is where hours go missing, so it is spelled out. **Two different OAuth clients** are
involved, and confusing them is the usual mistake.

| Client | What it does | Does it appear in the code |
|---|---|---|
| **Android** | identifies the app by package name and signing SHA-1 | **no** |
| **Web** | lets the app ask Google for a token of identity | **yes**, as `serverClientId` |

1. In the Google Cloud Console, enable the **Google Drive API**
2. Create an **Android OAuth client**: package `io.ringlex.scanote`, and the SHA-1 of the key you
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

`_databaseVersion` in `db_helper.dart` is **8**. Every schema change is a new
`if (oldVersion < N)` block in `_onUpgrade` — never a rebuilt table, because the user's notes
are in it.

### What protecting a note does not cover

The title stays in the clear, so the note can still be found. Only text notes can be protected,
not checklists. In the widget, a protected note shows as 🔒.

### Sync is last-write-wins, and deliberately narrow

Notes are matched across devices by `uuid`, never by row id — two phones both counting from 1
would hand the same id to different notes. When both sides changed a note the later
`updatedAt` wins outright, and a deletion travels as a **tombstone** rather than as an
absence, or the phone that has not heard about it would hand the note straight back.

Two things stay out of sync on purpose: **protected notes**, whose Keystore key cannot leave
the phone and which would otherwise need a passphrase prompt on every background pass, and
**scanned pictures**, which would bloat the document. Both are stated in the settings screen
and in the privacy policy — if you change either, change those too.

### Android's own backup is switched off

`allowBackup="false"` plus `res/xml/data_extraction_rules.xml`. The system backup would copy
the notes database to the cloud but **cannot copy the Keystore key**, so a restore onto a new
phone would produce protected notes that nothing can ever open. Moving notes between phones is
what the app's backup and sync are for.

### `USE_EXACT_ALARM` is not declared, on purpose

Play restricts it to alarm clocks and calendars. Only `SCHEDULE_EXACT_ALARM`, which the user
grants, is asked for. Do not add the other one back to make a reminder land to the minute — it
invites a policy rejection.

`flutter_local_notifications` declares `USE_EXACT_ALARM` in its own manifest, so ours strips it
with `tools:node="remove"`. Check the **packaged** manifest, not
`intermediates/merged_manifest`, which goes stale:

```bash
grep -c USE_EXACT_ALARM \
  build/app/intermediates/packaged_manifests/release/*/arm64-v8a/AndroidManifest.xml
```

`NotificationService` schedules exactly and falls back to a window when Android says no, and
settings offers a row that sends the user to grant it. Granting re-sets everything already
queued — `EventRepository.rescheduleReminders` — because a queued reminder keeps whatever mode
it was scheduled with.

## Before release

- [x] A **keystore** for signing — `~/.android/scanote-upload.jks`, with `android/key.properties`
      pointing at it. Without that file a release build silently falls back to the **debug**
      signing key and Play rejects it, so `tool/build_release.sh` refuses to run without it
- [ ] Register the upload key's **SHA-1** on an Android OAuth client, and — because Play
      re-signs the bundle — **a second client** carrying the fingerprint Google signs with
      (Play Console → Test and release → Setup → App integrity). One client holds one
      fingerprint, so each key needs its own
- [ ] Move the **consent screen** to production — in testing mode tokens expire after 7 days
- [ ] App name on the consent screen: **Scanote** (it tends to keep the old one)
- [x] [Privacy policy](https://ringlex.github.io/scanote-legal/privacy-policy.html) and
      [terms](https://ringlex.github.io/scanote-legal/terms-of-service.html) published from
      `Ringlex/scanote-legal`. The documents here stay the source — copy changes across, or
      the published text drifts from what the app does
- [ ] **Data safety form**: notes and categories go to Drive when sync or backup is on; the
      mic reaches the system recogniser; scans and protected notes never leave the phone
- [x] Screenshots, feature graphic, icon and both listings — [store/](store/)
- [ ] Tablet screenshots, and a `pl-PL` set, if the listing is to be localised
- [ ] Check the name "Scanote" in Google Play and at EUIPO
- [ ] Decide on a **monetisation** plan, or accept there is none

## Tests

Ten test files, including full cover of `NoteCipher` — encryption, the version byte,
detecting tampered text, and deriving a key from a passphrase — and of search matching.

```bash
fvm flutter test
```

The tests do not reach the native side: `BiometricPrompt`, the Keystore, the widget and
`ACTION_SEND` are checked on a device or not at all.
