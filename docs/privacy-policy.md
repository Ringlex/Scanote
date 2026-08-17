# Polityka prywatności — Scanote

**Ostatnia aktualizacja:** [UZUPEŁNIĆ DATĘ]
**Administrator danych:** [UZUPEŁNIĆ IMIĘ I NAZWISKO / NAZWĘ FIRMY]
**Kontakt:** [UZUPEŁNIĆ ADRES E-MAIL]

## W skrócie

Scanote nie ma własnych serwerów. Nie zbieramy statystyk, nie wyświetlamy reklam i nie
przekazujemy niczego reklamodawcom ani firmom analitycznym. Twoje notatki są przechowywane
w pamięci telefonu, a kopia zapasowa i synchronizacja — jeśli je włączysz — korzystają
z **Twojego** Dysku Google, nie naszego.

## Co zostaje wyłącznie na telefonie

- **Treść notatek, listy zadań, kategorie i wydarzenia** — w bazie danych aplikacji,
  w prywatnym katalogu, do którego inne aplikacje nie mają dostępu. Opuszczają telefon
  **tylko wtedy**, gdy sam włączysz kopię zapasową lub synchronizację (opisane niżej).
- **Zdjęcia skanowane w celu rozpoznania tekstu.** Rozpoznawanie działa **offline, na
  urządzeniu** (Google ML Kit z modelem wbudowanym w aplikację). Zdjęcie **jest zapisywane
  w pamięci telefonu i pozostaje przy notatce**, żebyś mógł wrócić do oryginału, gdy
  rozpoznany tekst okaże się niedokładny. **Nigdzie go nie wysyłamy** — nie trafia ani do
  kopii zapasowej, ani do synchronizacji. Możesz je usunąć pojedynczo w edytorze notatki,
  a skasowanie notatki usuwa jej zdjęcia razem z nią.
- **Kody QR i kreskowe** — odczytywane również lokalnie.
- **Notatki chronione** — ich treść jest szyfrowana algorytmem AES-256-GCM. Klucz
  przechowywany jest w sprzętowym magazynie kluczy Androida (Android Keystore) i **nigdy
  nie opuszcza urządzenia**. Odczytanie wymaga potwierdzenia tożsamości odciskiem palca
  lub blokadą ekranu.

## Co opuszcza telefon i w jakim celu

### Dyktowanie notatek

Gdy korzystasz z dyktowania, dźwięk jest przekazywany do **usługi rozpoznawania mowy
zainstalowanej na Twoim telefonie**. Na większości urządzeń z Androidem jest to usługa
Google, która może przetwarzać nagranie na swoich serwerach. Scanote nie nagrywa, nie
przechowuje ani nie przesyła dźwięku samodzielnie — otrzymuje wyłącznie gotowy tekst.
Przetwarzanie po stronie dostawcy rozpoznawania mowy podlega jego własnej polityce
prywatności.

### Logowanie kontem Google (opcjonalne)

Aplikacja działa bez logowania. Jeśli się zalogujesz, otrzymujemy z Twojego konta Google
**imię i nazwisko, adres e-mail, zdjęcie profilowe oraz identyfikator konta**. Dane te są
używane wyłącznie do wyświetlenia, kto jest zalogowany, i do autoryzacji dostępu do Dysku.
Nie są nigdzie przez nas wysyłane ani przechowywane poza Twoim telefonem.

### Kopia zapasowa na Dysku Google (opcjonalna)

Eksport zapisuje plik z notatkami na **Twoim własnym Dysku Google**. Aplikacja korzysta
z zakresu uprawnień `drive.file`, który daje dostęp **wyłącznie do plików utworzonych przez
tę aplikację** — nie widzimy i nie możemy odczytać żadnych innych Twoich plików na Dysku.

Notatki chronione są przed wysłaniem **ponownie szyfrowane hasłem kopii zapasowej**, które
podajesz przy eksporcie. Hasło to nie jest nigdzie zapisywane — ani na telefonie, ani na
Dysku. **Jeśli je zapomnisz, chronionych notatek z kopii nie odzyska nikt, łącznie z nami.**

### Synchronizacja między urządzeniami (opcjonalna)

Synchronizacja jest **domyślnie wyłączona**. Gdy ją włączysz w ustawieniach, aplikacja
utrzymuje jeden plik na **Twoim własnym Dysku Google** i zapisuje w nim Twoje notatki, listy
zadań, kategorie oraz informację o tym, które notatki zostały usunięte. Dzięki temu każdy
telefon zalogowany na to samo konto Google widzi ten sam zestaw notatek.

W odróżnieniu od kopii zapasowej **synchronizacja działa automatycznie**: plik jest
odświeżany po każdej zmianie notatki (z kilkusekundowym opóźnieniem) oraz przy ręcznym
uruchomieniu z ustawień. Obowiązuje ten sam zakres `drive.file` — widzimy wyłącznie plik
utworzony przez tę aplikację.

**Czego synchronizacja nie obejmuje:**

- **Notatek chronionych.** Ich klucz znajduje się w magazynie kluczy tego telefonu i nie może
  go opuścić, więc chronione notatki nigdy nie trafiają do pliku synchronizacji.
- **Zdjęć ze skanów.** Zostają w pamięci telefonu, na którym je zrobiono.

Synchronizację możesz wyłączyć w każdej chwili. Wyłączenie zatrzymuje wysyłanie, ale **nie
usuwa** pliku z Dysku — korzystają z niego Twoje pozostałe urządzenia. Plik możesz skasować
samodzielnie na swoim Dysku.

## Czego nie robimy

- Nie zbieramy danych analitycznych ani statystyk użycia.
- Nie zbieramy raportów o awariach.
- Nie wyświetlamy reklam i nie korzystamy z identyfikatorów reklamowych.
- Nie profilujemy użytkowników i nie podejmujemy decyzji w sposób zautomatyzowany.
- Nie sprzedajemy ani nie udostępniamy danych podmiotom trzecim.

Aplikacja nie posiada żadnego serwera, na który mogłaby wysyłać dane.

## Uprawnienia i po co są

| Uprawnienie | Do czego służy |
|---|---|
| Aparat | robienie zdjęć do rozpoznawania tekstu i kodów |
| Mikrofon | dyktowanie treści notatek |
| Powiadomienia | przypomnienia o wydarzeniach |
| Alarmy dokładne | przypomnienia o wyznaczonej godzinie |
| Uruchomienie po starcie | odtworzenie zaplanowanych przypomnień po restarcie telefonu |
| Internet | wyłącznie kopia zapasowa na Dysku Google i logowanie |
| Biometria | odblokowanie chronionych notatek |

Każdego z tych uprawnień możesz odmówić — aplikacja będzie działać, tracąc tylko związaną
z nim funkcję. Wyjątkiem są alarmy dokładne: bez tej zgody przypomnienia nadal przychodzą,
ale w przybliżonym czasie, a nie co do minuty.

## Usuwanie danych

Notatki usuwasz w aplikacji; trafiają najpierw do kosza, a po **30 dniach** są kasowane
trwale. Odinstalowanie aplikacji usuwa wszystkie dane z telefonu, w tym klucz szyfrujący —
**po odinstalowaniu chronionych notatek nie da się odzyskać nawet z kopii zapasowej zrobionej
na tym samym telefonie**, chyba że znasz hasło kopii.

Trwałe skasowanie notatki usuwa również **zdjęcia ze skanów**, które do niej należały.

Pliki kopii zapasowej i plik synchronizacji na Dysku Google należą do Ciebie — możesz je
usunąć samodzielnie w dowolnej chwili. Dostęp aplikacji do konta Google odbierzesz
w ustawieniach swojego konta Google, w sekcji aplikacji z dostępem.

Aplikacja **nie korzysta z automatycznej kopii zapasowej Androida**. Notatki chronione są
zaszyfrowane kluczem, którego systemowa kopia nie obejmuje, więc przywrócone na nowym
telefonie byłyby nieczytelne. Do przeniesienia notatek służy kopia zapasowa lub
synchronizacja opisane wyżej.

## Dzieci

Aplikacja nie jest kierowana do dzieci poniżej 13. roku życia i nie zbiera świadomie ich
danych.

## Zmiany

O istotnych zmianach tej polityki poinformujemy w opisie aktualizacji aplikacji. Data
ostatniej zmiany znajduje się na początku dokumentu.

## Kontakt

W sprawach dotyczących prywatności: [UZUPEŁNIĆ ADRES E-MAIL]

---

# Privacy Policy — Scanote

**Last updated:** [FILL IN DATE]
**Data controller:** [FILL IN NAME / COMPANY]
**Contact:** [FILL IN EMAIL ADDRESS]

## In short

Scanote has no servers of its own. We collect no analytics, show no adverts, and pass
nothing to advertisers or analytics companies. Your notes live in your phone's storage, and
backup and sync — if you turn them on — use **your** Google Drive, not ours.

## What never leaves the phone

- **Note contents, checklists, categories and events**, in the app's own database, in a
  private directory other apps cannot read. They leave the phone **only** if you turn on
  backup or sync yourself, both described below.
- **Photographs taken to read text from.** Recognition runs **offline, on the device**
  (Google ML Kit with a model bundled into the app). The photo **is saved on the phone and
  kept with the note**, so that you can go back to the original when the recognised text
  turns out to be wrong. **We never upload it** — it goes into neither the backup nor the
  sync. You can remove pictures one by one in the note editor, and deleting a note takes its
  pictures with it.
- **QR and barcodes**, also read locally.
- **Protected notes**, whose contents are encrypted with AES-256-GCM. The key is held in the
  Android Keystore and **never leaves the device**. Reading one requires your fingerprint or
  your screen lock.

## What does leave the phone, and why

### Dictation

When you dictate, the audio is passed to the **speech recognition service installed on your
phone**. On most Android devices this is Google's service, which may process the recording on
its own servers. Scanote does not record, store or transmit audio itself — it receives only
the finished text. Processing by the speech provider is governed by that provider's own
privacy policy.

### Signing in with Google (optional)

The app works without signing in. If you do sign in, we receive your **name, email address,
profile picture and account identifier** from Google. This is used only to show who is signed
in and to authorise access to Drive. It is not sent anywhere by us, and is not stored outside
your phone.

### Backup to Google Drive (optional)

Exporting writes a file of your notes to **your own Google Drive**. The app uses the
`drive.file` scope, which grants access **only to files this app created** — we cannot see or
read any of your other Drive files.

Protected notes are **re-encrypted with the backup passphrase** you choose at export time.
That passphrase is stored nowhere, neither on the phone nor on Drive. **If you forget it, the
protected notes in that backup cannot be recovered by anyone, ourselves included.**

### Sync across devices (optional)

Sync is **off by default**. When you turn it on in settings, the app keeps a single file on
**your own Google Drive** holding your notes, checklists, categories and a record of which
notes you deleted. That is what lets every phone signed in to the same Google account show
the same set of notes.

Unlike the backup, **sync runs by itself**: the file is refreshed after each change to a note
(a few seconds later) and whenever you run it by hand from settings. The same `drive.file`
scope applies — we see only the file this app created.

**What sync does not carry:**

- **Protected notes.** Their key lives in this phone's keystore and cannot leave it, so
  protected notes never go into the sync file.
- **Scanned pictures.** They stay on the phone that took them.

You can turn sync off at any time. Doing so stops the uploads but does **not** delete the
file from Drive, because your other devices are still using it. You may delete that file
yourself on your Drive.

## What we do not do

- No analytics or usage statistics.
- No crash reporting.
- No advertising and no advertising identifiers.
- No profiling and no automated decision-making.
- No selling or sharing of data with third parties.

The app has no server to send data to.

## Permissions and what they are for

| Permission | Purpose |
|---|---|
| Camera | photographing text and codes to read |
| Microphone | dictating note contents |
| Notifications | event reminders |
| Exact alarms | reminders at the time you set |
| Run at startup | restoring scheduled reminders after a reboot |
| Internet | Google Drive backup and signing in, nothing else |
| Biometrics | unlocking protected notes |

You may refuse any of these; the app keeps working and only loses the feature concerned. Exact
alarms are the exception: without that permission reminders still arrive, but around the time
you set rather than to the minute.

## Deleting your data

Notes you delete go to the bin first and are destroyed for good after **30 days**.
Uninstalling the app removes all data from the phone, including the encryption key —
**after uninstalling, protected notes cannot be recovered even from a backup made on that
same phone**, unless you know the backup passphrase.

Destroying a note for good also removes the **scanned pictures** that belonged to it.

Backup files and the sync file on Google Drive are yours and you may delete them at any
time. You can revoke the app's access to your Google account in your Google account
settings, under connected apps.

The app **does not use Android's automatic backup**. Protected notes are encrypted with a key
that the system backup cannot include, so restoring them onto a new phone would leave them
unreadable. Use the backup or the sync described above to move notes instead.

## Children

The app is not directed at children under 13 and does not knowingly collect their data.

## Changes

Material changes to this policy will be noted in the app's release notes. The date of the
last change is at the top of this document.

## Contact

For privacy matters: [FILL IN EMAIL ADDRESS]
