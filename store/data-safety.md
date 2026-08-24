# Data safety — odpowiedzi do Play Console

Deklaracja z **App content → Data safety**. Odpowiedzi wynikają z kodu, nie z życzeń —
przy każdej pozycji podane jest miejsce, z którego wynika. Zmiana w tych miejscach
wymaga poprawienia deklaracji, bo rozbieżność między nią a zachowaniem aplikacji to
podstawa do zdjęcia aplikacji ze sklepu.

## Sekcja 1 — pytania wstępne

| Pytanie | Odpowiedź |
|---|---|
| Czy aplikacja zbiera lub udostępnia wymagane typy danych? | **Tak** |
| Czy wszystkie zbierane dane są szyfrowane w tranzycie? | **Tak** — jedyne połączenia to Drive API i logowanie Google, oba po HTTPS |
| Czy użytkownik może zażądać usunięcia danych? | **Tak** |

Przy ostatnim pytaniu wybierz, że dane usuwa sam użytkownik: notatki idą do kosza i po
30 dniach znikają (`binRetention` w `lib/data/database/db_helper.dart`), odinstalowanie
kasuje wszystko z telefonu, a plik synchronizacji i kopie leżą na **jego własnym Dysku**
i może je skasować bez naszego udziału. Jako adres kontaktowy podaj ten sam co
w polityce prywatności.

## Sekcja 2 — typy danych

Zaznacz **wyłącznie** poniższe. Każdy jest **opcjonalny** (aplikacja działa bez
logowania i bez synchronizacji) i **żaden nie jest udostępniany** stronom trzecim —
„udostępnianie" w rozumieniu Play to przekazanie danych innemu podmiotowi, a Dysk
Google to konto użytkownika, nie nasze.

### Personal info → Name, Email address, User IDs

- **Zbierane:** tak. **Udostępniane:** nie. **Opcjonalne:** tak.
- **Cel:** App functionality, Account management.
- **Skąd:** logowanie kontem Google zwraca imię i nazwisko, adres e-mail, zdjęcie
  profilowe i identyfikator konta. Aplikacja pokazuje, kto jest zalogowany, i autoryzuje
  dostęp do Dysku. Nic z tego nie trafia na żaden nasz serwer, bo takiego nie ma.

### Files and docs

- **Zbierane:** tak. **Udostępniane:** nie. **Opcjonalne:** tak.
- **Cel:** App functionality (kopia zapasowa i synchronizacja).
- **Skąd:** przy włączonej synchronizacji `sync_repository.dart` wysyła na Dysk tytuły
  i treść notatek, listy zadań, nazwy kategorii oraz informację o tym, które notatki
  usunięto. Eksport zapisuje ten sam zakres do pliku kopii.

## Czego świadomie nie zaznaczasz

| Dane | Dlaczego nie |
|---|---|
| **Photos** — zdjęcia ze skanów | nigdy nie opuszczają telefonu; nie ma ich ani w synchronizacji, ani w kopii |
| **Audio** — dyktowanie | aplikacja nie nagrywa i nie przesyła dźwięku, tylko odbiera gotowy tekst z systemowej usługi rozpoznawania mowy; przetwarzanie leży po stronie dostawcy tej usługi i podlega jego deklaracji |
| **Notatki chronione** | pomijane w synchronizacji (`sync_repository.dart:144`), bo klucz nie opuszcza Keystore |
| **App activity, Device IDs, Crash logs, Diagnostics** | brak analityki, brak raportowania awarii, brak identyfikatorów reklamowych — nic takiego nie ma w `pubspec.yaml` |
| **Location, Contacts, Calendar, Health, Financial** | aplikacja ich nie dotyka |

## Dwie rzeczy, na których łatwo się pomylić

**Dane trafiają na Dysk użytkownika, nie do nas.** Play i tak każe je zadeklarować jako
zbierane, bo opuszczają urządzenie. Nie deklaruj ich jako **udostępnianych** — to pole
dotyczy przekazywania danych innemu podmiotowi, a tutaj użytkownik zapisuje własne dane
na własnym koncie. Zakres `drive.file` daje aplikacji dostęp wyłącznie do plików, które
sama utworzyła.

**„Opcjonalne" znaczy tu naprawdę opcjonalne.** Aplikacja działa bez logowania i bez
synchronizacji, więc przy każdej pozycji zaznacz, że zbieranie danych nie jest wymagane
do korzystania z aplikacji. To zauważalna różnica na karcie w sklepie.

## Zgodność z polityką prywatności

Deklaracja musi się zgadzać z <https://ringlex.github.io/scanote-legal/privacy-policy.html>.
Oba dokumenty mówią to samo: nie ma serwera, nie ma analityki, nie ma reklam, a to, co
opuszcza telefon, robi to na Dysk użytkownika i tylko wtedy, gdy sam to włączy.
