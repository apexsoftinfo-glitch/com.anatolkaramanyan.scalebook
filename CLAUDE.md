# Flutter Template - 12 Apps Challenge

> Ten szablon jest gotowy do konfiguracji pod nową aplikację kursanta wyzwania "12 Apps Challenge".
> CLAUDE.md jest budowany **stopniowo** — każdy krok dodaje sekcje potrzebne następnym krokom.

## ▶ Co dalej

**Następny krok:** `/start` — Discovery + IDEA.md
**Instrukcje:** `.claude/commands/start.md`

> Wpisz `/start` aby rozpocząć. Agent przeczyta plik z instrukcjami i przeprowadzi Cię przez cały proces.

---

## Stan projektu (SPRAWDŹ NA POCZĄTKU KAŻDEJ SESJI)

**ZANIM zrobisz COKOLWIEK**, sprawdź tę tabelę. Jeśli user prosi o coś co wymaga ukończenia wcześniejszego kroku → poinformuj go.

| Krok | Status | Kontekst | Next Action |
|------|--------|----------|-------------|
| /start | ✅ done | Pomysł ScaleBook zatwierdzony | Wpisz /home |
| /home | ✅ done | Wybrano Classic Workbench na tle maty | Wpisz /design |
| /design | ✅ done | Wybrano styl "The Tamiya Classic" | Wpisz /screens |
| /screens | ✅ done | Zaimplementowano UI i Design System | Wpisz /logic |
| /logic | ✅ done | Modele, Repozytoria i Cubity | Wpisz /onboarding |
| /onboarding | ✅ done | PageView i logika ukończenia | Wpisz /database |
| /database | ✅ done | SQLite/Hive i mechanizm backupu | Wpisz /auth |
| /auth | ✅ done | Autentykacja przez Supabase | Wpisz /limits |
| /limits | ✅ done | LimitPolicy (3 projekty dla gościa) | Wpisz /review |
| /review | ⬜ not-started | — | Najpierw /limits |
| /localize | ⬜ not-started | — | Najpierw /review |
| /finalize | ⬜ not-started | — | Najpierw /localize |

### Statusy per krok:

**Każdy krok ma statusy:**
- `not-started` → krok nie rozpoczęty
- `in-progress: [etap]` → krok w trakcie, [etap] opisuje gdzie jesteśmy
- `done` → krok ukończony, można przejść do następnego

### Reguły przejść:
- Każdy krok wymaga ukończenia poprzedniego
- Po każdej decyzji usera → aktualizuj Kontekst i Next Action
- Jeśli `in-progress` → proponuj kontynuację wg Next Action

### IDEA.md Sync (WAŻNE!)
Gdy cokolwiek się zmienia w flow/ekranach → **AKTUALIZUJ IDEA.md**
IDEA.md to single source of truth dla pomysłu i flow aplikacji.

### Edge cases:
- **Restart /start:** ustaw Status = `not-started`, wyczyść Kontekst
- **Zmiana pomysłu:** wróć do `/start`, zablokuj kolejne kroki
- **Prośby out-of-order:** wyjaśnij i skieruj do właściwego kroku
- **Stale session:** poproś o przypomnienie kontekstu

---

## Połączenie z platformą

> Wypełniana w `/start`. Bez ważnego API Key agent nie może synchronizować postępu.

- **API Key:** przechowywany w `.env` → `PLATFORM_API_KEY` (NIE w CLAUDE.md!)
- **Platform App ID:** 9005dcce-ef33-4054-81d6-25da5802738b
- **API Base URL:** https://auedkfdtobshqutwinee.supabase.co/functions/v1/apps-api

> **Uwaga o autoryzacji:** jedynym sposobem uwierzytelnienia jest nagłówek `X-API-Key`.
> Aktualne `GET /user` zwraca tylko: `first_name`, `last_name`, `agent_interview_about`,
> `agent_interview_completed_at`, `agent_interview_updated_at`. NIE zwraca `id`, `full_name`,
> `initial_programming_level`, `apps_stats` ani `agent_profile` — nie opieraj się na tych polach.

> **WAŻNE:** API Key jest w pliku `.env` (który jest w `.gitignore`). Agent czyta go stamtąd gdy potrzebuje.
> Nigdy nie commituj API Key do repozytorium!

### Synchronizacja statusów (WAŻNE!)

Przy KAŻDEJ zmianie statusu kroku agent MUSI:
1. Zaktualizować tabelę "Stan projektu" w tym pliku
2. Wysłać PATCH do platformy:

```bash
curl -X PATCH {API Base URL}/user/apps/{Platform App ID} \
  -H "X-API-Key: {API Key}" \
  -H "Content-Type: application/json" \
  -d '{"steps": [{"id": "{step_id}", "status": "{nowy_status}"}]}'
```

### Mapowanie kroków na step IDs

| Krok | Step ID (UUID) |
|------|----------------|
| /start | 683bbada-4e0e-4967-b04c-af6364597ab6 |
| /home | c0005d76-eafb-491e-af30-196451f7abee |
| /design | 850dfe85-0b06-4600-9444-c457121602d2 |
| /screens | 988edc7d-d08d-487f-b0b4-1a14b8b54a22 |
| /logic | 8ef1d6a0-a96c-4f20-ac29-7cb564e63ced |
| /onboarding | 7e50bdea-3a0a-4549-9b14-72d316c4b76c |
| /database | e227724b-b0fe-47b3-a1db-0075ac4b976d |
| /auth | 96069794-b06d-4db7-a01a-51f7cf263f1c |
| /limits | 66f6bb63-aba7-48a0-b432-7d8b60085b6f |
| /review | 0db9c2ee-df60-4ab6-af4e-1f3fbe683aa4 |
| /localize | 68e1dcfa-fcb6-422d-b9d5-3954a7949e80 |
| /finalize | 59006174-b4f3-4529-8457-c3c6c1dec5d4 |

> **Obsługa błędów API:**
> - `200` → OK.
> - `401` → niepoprawny/brakujący klucz. Poproś o nowy klucz i NIE kontynuuj flow.
> - `404`, `5xx`, timeout → traktuj jako chwilową niedostępność platformy/gatewaya (nie jako poprawną walidację klucza!). Zrób do 2 retry, potem zatrzymaj flow i poinformuj o niedostępności. Dla `PATCH` synchronizacji statusu: kontynuuj lokalnie i spróbuj zsynchronizować na końcu kroku.

---

## App Complexity Guidance

> Wypełniana w `/start`. Definicje tierów → `.claude/commands/start.md` (KROK 1.4).

- **App Number:** 6
- **Complexity Tier:** experienced

---

## Kontekst z poprzednich projektów

> Załadowane z platformy przy /start. Agent używa tych informacji aby lepiej pomagać.
> Ta sekcja jest PUSTA przy pierwszej aplikacji użytkownika.

### Trudności i rozwiązania (z poprzednich apek)

| Krok | Problem | Rozwiązanie | Apka |
|------|---------|-------------|------|
| — | — | — | — |

### Wnioski z ukończonych apek

[puste - wypełniane po ukończeniu pierwszej aplikacji]

---

## Dane użytkownika

> Część z tych pól pobierana jest z `GET /user` (`first_name`, `last_name`, `agent_interview_about`,
> `agent_interview_completed_at`, `agent_interview_updated_at`). Reszta — pytaj usera lub wyliczaj.

- **Imię i nazwisko:** Anatol Karamanyan
- **Wiek:** [pytaj usera w wywiadzie — API publicznie nie zwraca birth_year]
- **Poziom programowania:** [ustalany lokalnie przez `communication_mode` w sekcji "Styl komunikacji"]
- **Liczba ukończonych apek:** 4 (Magazynier, MobiScan, EasyNAVI, AutoWorld164)
- **Liczba apek w trakcie:** 1 (ProjectVault - 5/12 kroków)
- **Returning user?** tak
- **Krótkie podsumowanie wywiadu (returning user):** Entuzjasta IT, który pasjonuje się automatyzacją procesów. Lubi znajdować technologiczne rozwiązania dla powtarzalnych zadań i optymalizować codzienne czynności za pomocą informatyki.

---

## Konfiguracja aplikacji

- **Bundle ID:** com.anatolkaramanyan.scalebook
- **App Display Name:** ScaleBook
- **App Package Name:** scalebook
- **Table Prefix:** sb_

---

## Styl komunikacji

**communication_mode:** advanced

**commit_mode:** ask

> Definicje trybów → `.claude/commands/start.md` (KROK 5).
> **auto** = commit po "ok". **ask** = pytaj w kluczowych momentach. **manual** = user sam commituje.

---

## Struggles (dla Agenta AI)

> `GET /user` NIE zwraca `agent_profile`, więc nie da się zrobić `GET → merge → PATCH` tego pola.
> Agent utrzymuje `agent_profile` (w tym `struggles[]`) jako **narastający obiekt w pamięci sesji**
> i przy każdym `PATCH /user` wysyła pełny aktualny `agent_profile`. Po zakończeniu sesji stan
> pozostaje po stronie platformy; w kolejnej sesji agent buduje go od nowa z tego, co wynika
> z CLAUDE.md, notatek oraz `agent_interview_about`.

---

## Backlog (do zrobienia w przyszłych krokach)

> Rzeczy które ustaliliśmy w poprzednich krokach, że zrobimy później.
> **Agent:** Na początku kroku sprawdź czy jest coś dla Ciebie. Na końcu kroku dodaj jeśli coś odkładasz.

| Zrobić w | Co | Kontekst (skąd wiemy) |
|----------|-----|----------------------|
| — | — | — |

---

## Notatki per krok

> Krótkie podsumowania po każdym kroku. Kluczowe ustalenia, decyzje, preferencje usera.
> **Agent:** Na początku kroku przeczytaj WSZYSTKIE poprzednie notatki. Na końcu kroku zapisz swoje.

### /start
ScaleBook - aplikacja dla modelarzy (plastykowe, figurki 1/24). Core: Build Log + Galeria + Export Kolaży. Model non-profit (buycoffee.to). Backup lokalny ZIP. Offline-first.

### /home
Wybrano layout "Classic Workbench" (siatka kart) z tłem z "The Kanban Bench" (techniczna mata modelarska). Skupienie na dużych zdjęciach i postępie prac.

### /design
Wybrano styl "The Tamiya Classic". Paleta: Navy Blue, White, Red. Typografia Sans-Serif, ikony techniczne. Design ma budzić skojarzenia z wysokiej jakości zestawami modelarskimi.

### /screens
Zbudowano szkielet UI: Design System (AppTheme, AppColors), CuttingMatBackground, WelcomeScreen, HomeScreen (grid modeli), ModelDetailScreen (tabs + timeline) oraz SettingsScreen. Kod przeszedł analizę bez błędów.

### /logic
Zdefiniowano modele domenowe (`ModelProject`, `BuildStep`) zgodnie z wymogami Freezed 3.0 (klasy `abstract`). Stworzono `ModelsRepository` z fejkowa implementacją oraz Cubity: `HomeCubit` i `ModelDetailCubit`. Zależności zarejestrowano w GetIt. Całość zintegrowano z widokami.

### /onboarding
Zaimplementowano `OnboardingScreen` z `PageView`, który prezentuje kluczowe funkcje aplikacji (Build Log, Portfolio, Backup). Zintegrowano `WelcomeScreen` z `FakeSessionRepository`, umożliwiając start jako gość. `AppGate` automatycznie kieruje do onboardingu, a po jego zakończeniu (aktualizacja profilu) do ekranu głównego. Dodano `shared_preferences` do `pubspec.yaml`.

### /database
Zaimplementowano warstwę trwałości danych opartą na plikach JSON (`LocalModelsRepository`) oraz system przechowywania zdjęć (`ImageService`). Stworzono `BackupService`, który umożliwia eksport całej kolekcji do pliku ZIP i jego udostępnianie (Share Sheet). System jest w pełni lokalny i gotowy do integracji z chmurą w kolejnych krokach.

### /auth
Zaimplementowano pełny system autentykacji oparty na Supabase. Stworzono `SupabaseAuthDataSource` i `SupabaseSessionRepository`, które zastąpiły wersje "fake". Dodano ekran `AuthScreen` umożliwiający logowanie i rejestrację przez email/password. System obsługuje teraz sesje anonimowe (Guest) oraz zarejestrowane, z automatycznym odświeżaniem profilu. Zaktualizowano `OnboardingScreen` i `WelcomeScreen` do pracy z nową architekturą.

### /limits
Zaimplementowano politykę limitów zgodną z modelem non-profit. Niezarejestrowani goście mają limit 3 projektów, natomiast użytkownicy zarejestrowani mają nielimitowany dostęp. Dodano `LimitDialog` w stylu Tamiya oraz licznik projektów w nagłówku `HomeScreen`, który informuje gości o pozostałym miejscu i zachęca do rejestracji.

### /review
[puste]

### /localize
[puste]

### /finalize
[puste]

---

## Dostępne Narzędzia

### Komendy (Slash Commands)

> **WAŻNE:** Każda komenda ma SZCZEGÓŁOWE instrukcje w `.claude/commands/{nazwa}.md`.
> Agent MUSI przeczytać odpowiedni plik PRZED wykonaniem kroku!
> Jeśli user wpisze nazwę kroku BEZ slasha (np. "start", "wireframes") → traktuj identycznie jak `/start`, `/home` itd.

| Komenda | Kiedy używać | Plik z instrukcjami |
|---------|--------------|---------------------|
| **/start** | Discovery + IDEA.md | `.claude/commands/start.md` |
| **/home** | 5 radykalnie różnych layoutów, wybór jednego | `.claude/commands/home.md` |
| **/design** | 5 radykalnie różnych stylów, wybór jednego | `.claude/commands/design.md` |
| **/screens** | Reszta ekranów + Settings + shared components | `.claude/commands/screens.md` |
| **/logic** | Cubity + Repo + FakeDataSource + testy | `.claude/commands/logic.md` |
| **/onboarding** | Welcome + Guided Onboarding od zera | `.claude/commands/onboarding.md` |
| **/database** | Supabase single-user | `.claude/commands/database.md` |
| **/auth** | Login/Register + RevenueCat + pełny SessionRepository | `.claude/commands/auth.md` |
| **/limits** | LimitPolicy, UpgradeDialogs (Guest→Registered→Pro) | `.claude/commands/limits.md` |
| **/review** | Ask for review prompt | `.claude/commands/review.md` |
| **/localize** | L10N (PL + EN) + przełącznik języka | `.claude/commands/localize.md` |
| **/finalize** | Posprzątaj CLAUDE.md, przygotuj do dalszego dev | `.claude/commands/finalize.md` |

### Skille

Dobieraj skille na podstawie kontekstu zadania:

| Skill | Kiedy używać |
|-------|--------------|
| **flutter-mobile-design** | Design wariantów, wysokiej jakości UI, kolory, typography, tokens |
| **flutter-ui** | Tworzenie ekranów, widgetów, stylowanie, animacje, UX, formularze |
| **flutter-logic** | Architektura, Feature'y, Cubity, Modele, Repozytoria, Testy, logika biznesowa |
| **flutter-backend** | Integracja z Supabase, DataSource, zewnętrzne API |
| **guided-onboarding** | Tylko do prac nad Guided Onboarding |
| **supabase-auth** | Auth, login/logout, anonymous users, session, linking accounts, AuthGate |
| **flutter-localization** | i18n, ARB files, przełącznik języka, tłumaczenia PL/EN |

---

## Zasady dla Agenta AI

### ZAWSZE rób
- **Na koniec KAŻDEGO taska:** `flutter analyze` i wyczyść WSZYSTKO - zero błędów, zero warningów, zero info
- **Zahardcodowane stringi ZAWSZE oznaczaj `// L10N`** - to KRYTYCZNE dla późniejszej lokalizacji!
  ```dart
  // ✅ DOBRZE - string oznaczony
  Text('Witaj w aplikacji'), // L10N

  // ❌ ŹLE - string bez oznaczenia (zgubi się przy lokalizacji!)
  Text('Witaj w aplikacji'),
  ```
  **Gdzie oznaczać:** Text(), hintText, labelText, title w AppBar/Dialog, SnackBar, buttony, placeholder, empty states
- **Sprawdź `App Complexity Guidance`** — dostosuj złożoność do tieru (starter = mega prosto, master = pushuj AI)
- **Sprawdzaj "Stan projektu"** na początku każdej sesji - jeśli `in-progress`, zaproponuj kontynuację
- Aktualizuj `CHANGELOG.md` po zakończeniu pracy
- **Sprawdź `commit_mode`** przed każdym commitem (auto/ask/manual)
- **Dostosuj język** do `communication_mode` usera (beginner/intermediate/advanced)

> **Więcej zasad** (architektura, coding rules, commit rules) jest dodawanych przez kolejne komendy w miarę postępu projektu.
