#!/usr/bin/env bash
#
# Buduje podpisany App Bundle do wydania na Google Play.
#
#   ./tool/build_release.sh              # zwykly przebieg
#   ./tool/build_release.sh --clean      # z wyczyszczeniem posrednich artefaktow
#   ./tool/build_release.sh --skip-checks
#
# Wynik: output/note.aab
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

OUTPUT_DIR="$PROJECT_ROOT/output"
ARTIFACT_NAME="note.aab"
BUNDLE_PATH="build/app/outputs/bundle/release/app-release.aab"
KEY_PROPERTIES="android/key.properties"

# Gradle potrafi zajac kilka gigabajtow w katalogu domowym. Ponizej tego progu
# build zwykle umiera w polowie na bledzie, ktory nie mowi nic o miejscu.
MIN_FREE_GB=5

DO_CLEAN=0
SKIP_CHECKS=0

for arg in "$@"; do
  case "$arg" in
    --clean) DO_CLEAN=1 ;;
    --skip-checks) SKIP_CHECKS=1 ;;
    -h|--help) sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Nieznany argument: $arg" >&2; exit 2 ;;
  esac
done

say()  { printf '\n\033[1m==> %s\033[0m\n' "$1"; }
fail() { printf '\033[31mBLAD: %s\033[0m\n' "$1" >&2; exit 1; }
warn() { printf '\033[33mUWAGA: %s\033[0m\n' "$1" >&2; }

# Projekt jest przypiety do wersji Fluttera w .fvmrc, wiec budujemy przez fvm.
# Budowanie wydania inna wersja niz deweloperska to proszenie sie o roznice,
# ktore wyjda dopiero u uzytkownikow.
if command -v fvm >/dev/null 2>&1 && [ -f .fvmrc ]; then
  FLUTTER=(fvm flutter)
else
  command -v flutter >/dev/null 2>&1 || fail "Nie znaleziono ani fvm, ani flutter w PATH."
  FLUTTER=(flutter)
  warn "Buduje globalnym flutterem — .fvmrc wskazuje inna wersje niz uzyta."
fi

# --- kontrole przed budowaniem -----------------------------------------------

if [ "$SKIP_CHECKS" -eq 0 ]; then
  say "Kontrole przed budowaniem"

  # Bez key.properties Gradle po cichu podpisuje kluczem debug. Plik zbuduje sie
  # bez jednego ostrzezenia i zostanie odrzucony dopiero przez Google Play,
  # zwykle po kwadransie czekania na upload.
  if [ ! -f "$KEY_PROPERTIES" ]; then
    fail "Brak $KEY_PROPERTIES — build podpisalby sie kluczem debug i Play go odrzuci.
     Utworz plik z zawartoscia:
       storeFile=/pelna/sciezka/do/upload-keystore.jks
       storePassword=...
       keyAlias=upload
       keyPassword=..."
  fi

  STORE_FILE="$(grep -E '^storeFile=' "$KEY_PROPERTIES" | cut -d= -f2- || true)"
  [ -n "$STORE_FILE" ] || fail "$KEY_PROPERTIES nie zawiera storeFile."

  # Sciezka wzgledna w key.properties jest liczona od katalogu android/.
  case "$STORE_FILE" in
    /*) RESOLVED_STORE="$STORE_FILE" ;;
    *)  RESOLVED_STORE="$PROJECT_ROOT/android/$STORE_FILE" ;;
  esac

  [ -f "$RESOLVED_STORE" ] || fail "Keystore nie istnieje: $RESOLVED_STORE"
  echo "Keystore: $RESOLVED_STORE"

  # Gradle pisze do katalogu domowego, ktory bywa na innym wolumenie niz projekt.
  GRADLE_HOME="${GRADLE_USER_HOME:-$HOME/.gradle}"
  mkdir -p "$GRADLE_HOME"
  FREE_GB="$(df -g "$GRADLE_HOME" | awk 'NR==2 {print $4}')"

  if [ "${FREE_GB:-0}" -lt "$MIN_FREE_GB" ]; then
    fail "Na wolumenie z $GRADLE_HOME zostalo ${FREE_GB}G, potrzeba co najmniej ${MIN_FREE_GB}G.
     Zwolnij miejsce albo przenies cache Gradle na inny dysk:
       export GRADLE_USER_HOME=/Volumes/INNY_DYSK/gradle"
  fi
  echo "Wolne miejsce dla Gradle: ${FREE_GB}G"

  # bundletool sklada .aab w katalogu tymczasowym JVM, a ten lezy na dysku
  # systemowym niezaleznie od GRADLE_USER_HOME. Build przechodzi wtedy cala
  # kompilacje i pada dopiero na pakowaniu, na "No space left on device".
  JVM_TMP="${TMPDIR:-/tmp}"
  TMP_FREE_GB="$(df -g "$JVM_TMP" | awk 'NR==2 {print $4}')"

  if [ "${TMP_FREE_GB:-0}" -lt "$MIN_FREE_GB" ]; then
    fail "Na wolumenie z katalogiem tymczasowym ($JVM_TMP) zostalo ${TMP_FREE_GB}G,
     potrzeba co najmniej ${MIN_FREE_GB}G. Przekieruj go na inny dysk:
       ln -sfn /Volumes/INNY_DYSK/build-tmp ~/build-tmp
       export TMPDIR=~/build-tmp
       export _JAVA_OPTIONS=-Djava.io.tmpdir=\$HOME/build-tmp
     Sciezka musi byc bez spacji — _JAVA_OPTIONS dzieli argumenty po spacji,
     wiec /Volumes/JAKIS DYSK/tmp dojdzie do JVM jako /Volumes/JAKIS."
  fi
  echo "Wolne miejsce dla katalogu tymczasowego: ${TMP_FREE_GB}G"

  VERSION="$(grep -E '^version:' pubspec.yaml | awk '{print $2}')"
  echo "Wersja z pubspec.yaml: $VERSION"
fi

# --- budowanie ---------------------------------------------------------------

if [ "$DO_CLEAN" -eq 1 ]; then
  say "Czyszczenie"
  "${FLUTTER[@]}" clean
fi

say "Pobieranie zaleznosci"
"${FLUTTER[@]}" pub get

say "Generowanie kodu (freezed, json_serializable)"
"${FLUTTER[@]}" pub run build_runner build --delete-conflicting-outputs

say "Analiza"
# Wydanie z bledami analizy to wydanie, ktorego nikt nie przejrzal.
"${FLUTTER[@]}" analyze

say "Testy"
"${FLUTTER[@]}" test

say "Budowanie App Bundle"
"${FLUTTER[@]}" build appbundle --release

# --- wynik -------------------------------------------------------------------

[ -f "$BUNDLE_PATH" ] || fail "Build sie zakonczyl, ale nie ma pliku $BUNDLE_PATH"

mkdir -p "$OUTPUT_DIR"
cp "$BUNDLE_PATH" "$OUTPUT_DIR/$ARTIFACT_NAME"

say "Gotowe"
printf '%s (%s)\n' "$OUTPUT_DIR/$ARTIFACT_NAME" "$(du -h "$OUTPUT_DIR/$ARTIFACT_NAME" | cut -f1)"

# Podpis warto zobaczyc na wlasne oczy: jesli w wyniku widnieje "CN=Android Debug",
# to znaczy, ze Gradle mimo wszystko uzyl klucza debug.
if command -v keytool >/dev/null 2>&1; then
  echo
  echo "Podpis:"
  unzip -p "$OUTPUT_DIR/$ARTIFACT_NAME" META-INF/*.RSA 2>/dev/null \
    | keytool -printcert 2>/dev/null \
    | grep -E "Owner|Valid" || echo "  (nie udalo sie odczytac — sprawdz recznie przed wysylka)"
fi
