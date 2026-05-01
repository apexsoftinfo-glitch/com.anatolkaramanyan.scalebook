# Changelog

## Standard wpisów (obowiązkowy)

- Dodawaj nowe wpisy zawsze **na górze** pliku (zaraz pod tą sekcją).
- Używaj układu: `## RRRR-MM-DD` + krótka lista najważniejszych zmian.
- Pisz **prostym, zrozumiałym językiem** (bez technicznego żargonu).
- Skupiaj się na tym, co realnie poprawiono z perspektywy użytkownika/procesu.
- Każdy punkt zaczynaj od czasownika w czasie przeszłym (np. „Dodano”, „Poprawiono”, „Uproszczono”).
- Pomijaj długie szczegóły implementacyjne, chyba że są kluczowe dla zrozumienia zmiany.
- Opcjonalnie używaj emoji dla czytelności, ale bez przesady.

## 2026-05-01

- Wycofano się z zawodnych zewnętrznych zdjęć na rzecz **w pełni programowalnego, technicznego tła maty modelarskiej**.
- Nowe tło jest generowane w czasie rzeczywistym, co eliminuje błędy wczytywania i gwarantuje 100% czystości (brak osób/niechcianych elementów).
- Dodano techniczne detale: miarki na krawędziach, oznaczenia kątowe, oznaczenia skali ("1/24 SCALE WORKBENCH") oraz profesjonalną głębię kolorystyczną (Navy Blue).
- Skonfigurowano i wygenerowano poprawną ikonę aplikacji (ScaleBook) dla systemów Android i iOS.
- Naprawiono problem wylogowywania użytkownika po restarcie aplikacji – sesja jest teraz poprawnie przywracana z pamięci urządzenia.
- Dodano funkcję usuwania etapów budowy – przesuń wpis w lewo, aby zobaczyć ikonę kosza i potwierdzić usunięcie.
- Poprawiono widok podglądu zdjęć – teraz otwierają się na prawdziwym pełnym ekranie (bez paska systemowego), co pozwala na jeszcze lepsze wykorzystanie zoomu.
- Zoptymalizowano widok historii budowy – zdjęcia są teraz mniejsze i umieszczone obok tekstu, dzięki czemu na ekranie mieści się więcej wpisów.
- Dodano możliwość powiększania zdjęć do pełnego ekranu oraz ich przybliżania (zoom) przy użyciu gestów.
- Dodano możliwość edycji istniejących etapów budowy (wystarczy kliknąć we wpis w historii).
- Naprawiono błąd wyświetlania zdjęć modeli na ekranie głównym (poprawne wczytywanie plików lokalnych).
- Dodano możliwość wyboru źródła zdjęcia (Aparat lub Galeria) przy dodawaniu modelu i etapów budowy.
- Wprowadzono wymóg dodania zdjęcia (opakowania lub modelu) oraz nazwy przy tworzeniu nowego projektu.
- Dodano możliwość wyboru daty rozpoczęcia projektu (domyślnie ustawiona na dzisiaj).
- Przetłumaczono interfejs dodawania modelu na język polski.
- Aktywowano możliwość dodawania zdjęć do etapów budowy przy użyciu galerii telefonu.
- Zaimplementowano `ImageService` do bezpiecznego zapisywania zdjęć w pamięci lokalnej urządzenia.
- Poprawiono wyświetlanie zdjęć w historii budowy, wspierając zarówno pliki lokalne, jak i adresy sieciowe.
- Poprawiono logikę logowania, aby aplikacja pamiętała sesję użytkownika i nie wylogowywała go automatycznie przy każdym restarcie.
- Przetłumaczono interfejs szczegółów projektu na język polski (m.in. "DODAJ ETAP", "HISTORIA BUDOWY", "GALERIA").
- Dodano możliwość usuwania projektów poprzez przytrzymanie karty na ekranie głównym.
- Wprowadzono system potwierdzeń z ostrzeżeniem o nieodwracalności operacji usuwania.

## 2026-02-24

- Dopracowano ustawienia iOS pod iPhone i nowsze wersje systemu.
- Uporządkowano konfigurację projektu iOS, żeby template był łatwiejszy do użycia po sklonowaniu.
- Usunięto zbędne dane deweloperskie z projektu Xcode, które utrudniały przenoszenie szablonu.
- Ujednolicono zachowanie aplikacji na Androidzie pod orientację pionową, żeby było spójnie z iOS.

## 2026-02-23

- Uporządkowano zasady śledzenia plików iOS w repozytorium.
- Ulepszono szablony dokumentacji: dodano sekcję szybkiego efektu i lepiej wyjaśniono podejście do danych.
- Usunięto zbędną deklarację dotyczącą szyfrowania w iOS.

## 2026-02-16

- Uproszczono `.gitignore`, usuwając niepotrzebny wpis.

## 2026-02-13

- Dodano obowiązkowy krok końcowej kontroli jakości (`flutter analyze`) w finalizacji.
- Wzmocniono zasadę natychmiastowego domykania kroku po akceptacji użytkownika.
- Doprecyzowano zasady tworzenia modeli danych w logice.

## 2026-02-12

- Dodano konfigurację iOS (`Podfile`), żeby projekt był gotowy do dalszych prac bez ręcznych poprawek.

## 2026-02-10

- Uzupełniono konfigurację iOS (`Podfile`) dla stabilniejszego startu projektu.
- Podniesiono minimalną wersję Androida dla lepszej zgodności i bezpieczeństwa.
- Poprawiono flow subskrypcji i paywalla, żeby uniknąć błędnych identyfikatorów planów.

## 2026-02-08

- Dodano gotowe strategie pokazywania korzyści premium w kluczowych krokach template’u.
- Rozszerzono dokumentację o konkretne przykłady funkcji premium.

## 2026-02-07

- Dodano zabezpieczenia, które zmniejszają ryzyko crashy przy konfiguracji płatności.
- Naprawiono problem z RevenueCat, gdy SDK nie było jeszcze poprawnie ustawione.
- Doprecyzowano krok związany z przeniesieniem `MainActivity.kt` przy zmianie Bundle ID.

## 2026-02-05

- Usprawniono konfigurację podpisywania wersji release.
- Lepiej przygotowano projekt pod publikację przez CI/CD (Codemagic).
- Uporządkowano strukturę `.gitignore`.

## 2026-02-04

- Ujednolicono konfigurację podpisywania Androida i uproszczono jej opis.
- Dostosowano ustawienia release pod CI/CD.
- Przeniesiono część konfiguracji podpisu do bezpieczniejszego, czytelniejszego układu.

## 2026-02-02

- Uporządkowano odwołania do skilli w komendach (pełne ścieżki zamiast skrótów).
- Dodano lepszą synchronizację statusów kroków z platformą.
- Posprzątano drobne błędy w finalizacji `/start`.
- Rozdzielono dane lokalne od danych wysyłanych na platformę (mniej ryzyka przypadkowego nadpisania).

## 2026-02-01

- Uproszczono flow limitów: agent sam dobiera typ limitu bez dodatkowego pytania.
- Rozbito duże pliki instrukcji na mniejsze kroki, dzięki czemu proces jest czytelniejszy.
- Poprawiono i odchudzono `/start`, usuwając zbędny szum.
- Wymuszono poprawną konfigurację Bundle ID przed zamknięciem kroku `/start`.
- Przeniesiono projektowanie modelu danych do właściwego etapu (`/logic`).
- Dodano lepszy kontekst aplikacji (numer appki i poziom złożoności).
- Doprecyzowano wymaganie czytania `CLAUDE.md` na początku każdej nowej sesji.
