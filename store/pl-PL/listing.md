# Listing w Play — pl-PL

Każdy blok wklej do odpowiadającego mu pola w Play Console. Play liczy znaki razem ze
spacjami; liczby przy blokach to ich dzisiejsza długość.

Zrzuty ekranu dla tej lokalizacji jeszcze nie istnieją — trzeba je zrobić z aplikacją
przełączoną na polski i złożyć tym samym `source/compose.py`.

## Nazwa aplikacji (maks. 30)

```
Scanote: skan na notatkę
```

## Krótki opis (maks. 80)

```
Zrób zdjęcie kartki, dostaniesz notatkę do przeszukania. Tekst czyta offline.
```

## Pełny opis (maks. 4000)

```
Scanote zamienia zdjęcie kartki w notatkę, którą można przeszukać, poprawić i odhaczyć.

Skieruj aparat na stronę z wykładu, paragon, przepis albo listę zakupów napisaną ręcznie.
Tekst zostaje rozpoznany na telefonie — zdjęcie nie jedzie w tym celu na żaden serwer, a
całość działa w trybie samolotowym. Fotografia zostaje przy notatce, więc zawsze można do
niej wrócić i przeczytać to, czego rozpoznawanie nie dało rady odczytać.

Zeskanowana lista przychodzi jako lista zadań. Odhaczasz po kolei.

CO POTRAFI

• Skanuje kartkę i wyciąga z niej tekst — rozpoznawanie działa na urządzeniu, offline
• Trzyma kilka stron w jednej notatce, razem ze zdjęciami
• Szuka także w treści odczytanej ze zdjęć, nie tylko w tym, co wpisałeś
• Zamienia zeskanowaną listę w listę zadań do odhaczenia
• Nagłówki, pogrubienia i listy widać jako formatowanie, nie jako surowe znaki
• Dyktowanie notatki, gdy ręce są zajęte
• Kategorie i ulubione, żeby stos nie urósł bez ładu
• Kalendarz z terminami i przypomnieniami, w tej samej aplikacji
• Widżet na ekranie głównym z ostatnio zapisaną notatką
• Udostępnianie notatki kodem QR, który odczyta drugi telefon
• Motyw jasny i ciemny
• Polski i angielski

NOTATKI, KTÓRE OTWIERA TYLKO TWÓJ ODCISK PALCA

Notatkę można oznaczyć jako chronioną. Zostaje wtedy zaszyfrowana algorytmem AES-256-GCM
kluczem trzymanym w Android Keystore. Ten klucz nie opuszcza telefonu — ani w kopii
zapasowej, ani do nas, ani do nikogo. Otwarcie notatki prosi o odcisk palca lub blokadę
ekranu.

Skoro klucz zostaje na telefonie, notatki chronione są świadomie pominięte w
synchronizacji. Zostają na tym telefonie, na którym powstały.

SYNCHRONIZACJA I KOPIA, JEŚLI ICH CHCESZ

Synchronizacja jest opcjonalna i wyłączona, dopóki jej nie włączysz. Gdy ją włączysz,
notatki wędrują przez Twój własny Dysk Google — Scanote prosi wyłącznie o dostęp do
plików, które sam utworzył, nigdy do reszty Dysku. Skany i notatki chronione zostają na
telefonie.

Całą bazę można też wyeksportować do pliku i wczytać ją na innym telefonie.

USUNIĘTA NOTATKA NIE ZNIKA OD RAZU

Usunięte notatki czekają w koszu trzydzieści dni, zanim znikną na dobre.

BEZ KONTA

Scanote działa bez logowania się gdziekolwiek. O konto Google pyta dopiero wtedy, gdy
włączysz synchronizację, i tylko o pliki, które sam na Dysku założył.

Nie ma reklam.
```

## Uwagi do Console

- Kategoria: Produktywność
- Tagi: notatki, skaner, OCR, lista zadań, szyfrowanie
- Adres e-mail, URL polityki prywatności i regulaminu wciąż do uzupełnienia; polityka
  musi wisieć pod publicznym adresem, zanim listing pójdzie do weryfikacji.
