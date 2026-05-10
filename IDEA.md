# ScaleBook

> Portfolio i build log dla modelarzy - trzymaj historię swoich budów w jednym, estetycznym miejscu.

- **App Display Name:** ScaleBook
- **Bundle ID:** com.anatolkaramanyan.scalebook
- **Description (EN):** ScaleBook is a dedicated portfolio and build log for scale modelers. Track your progress, separate hobby photos from your private gallery, and share beautiful build stories with the community.

---

## Wizja twórcy

> "Pojawił się pomysł stworzenia aplikacji mobilnej dla modelarzy, która pomagałaby uporządkować i prezentować swoje zbudowane modele oraz całe historie budowy."

- *"Przechowywać zdjęcia z budowy modelu i układać je chronologicznie, razem z własnymi uwagami"*
- *"Oddzielić zdjęcia modelarskie od prywatnych zdjęć w telefonie"*
- *"Prowadzić Magazyn (Stash) modeli oczekujących na budowę"*
- *"Prezentować ukończone dzieła w wirtualnej Gablocie (Showcase)"*
- *"Eksportować historię budowy i gotowe modele do social mediów (kolaże, plakaty)"*
- *"Projekt non-profit, darmowy dla wszystkich, z limitem 3 projektów dla gości zachęcającym do rejestracji"*
- *"Pełna synchronizacja projektów z chmurą (Supabase) przy zachowaniu lokalnego przechowywania zdjęć. Backup ZIP zawiera komplet danych."*

---

## Złota Nisza (SLC - Simple, Lovable, Complete)

**Problem:** Zdjęcia modeli plastikowych (często dziesiątki ujęć z budowy) mieszają się z prywatnymi zdjęciami w galerii telefonu. Brakuje uporządkowanego archiwum "build logów" i łatwego sposobu na ich estetyczną prezentację.

**Rozwiązanie:** Dedykowana przestrzeń do dokumentowania budowy modeli od A do Z, z podziałem na etapy prac i galerię końcową, bez zaśmiecania chmury zdjęć prywatnych.

**Dla kogo:** Modelarze plastikowi (auta, samoloty, czołgi) oraz twórcy figurek (skala 1/24 i inne).

**Dlaczego teraz:** Modelarstwo przeżywa renesans w social mediach, a użytkownicy szukają narzędzi do lepszego "storytellingu" swoich projektów.

**15-Minute Win:** Użytkownik dodaje swój pierwszy model, wrzuca 3 zdjęcia z dzisiejszej sesji budowy z krótką notatką i widzi, jak pięknie zaczyna wyglądać jego cyfrowy build log.

---

## Ekrany

### Lista wszystkich ekranów

| Ekran | Cel | Priorytet |
|-------|-----|-----------|
| Welcome | Pierwsze wrażenie, wejście w tryb gościa | CORE |
| Onboarding (8 stron) | Wprowadzenie w świat modelarstwa | CORE |
| Home (Pulpit) | Aktywne projekty ("W budowie") | CORE |
| Showcase (Gablota) | Galeria ukończonych modeli | CORE |
| Notes (Notatki) | Notatki warsztatowe i techniczne | CORE |
| Stash (Magazyn) | Modele czekające w kolejce | CORE |
| Model Detail | Historia budowy + Galeria końcowa | CORE |
| Present Model | Generowanie plakatu/kolażu do eksportu | CORE |
| Settings | Backup ZIP, Język, Profil | CORE |
| Login / Register | Synchronizacja chmury (Supabase) | AUTH |

---

## Home Screen

**Layout:** Classic Workbench Grid na technicznym tle. Siatka kart projektów wyświetlana na tle przypominającym matę modelarską (technical cutting mat) z delikatną siatką i liniami pomocniczymi.

**Elementy:**
- **Karta modelu:** Duże zdjęcie główne (hero shot), zaokrąglone rogi.
- **Progress Bar:** Pasek pod zdjęciem wskazujący postęp budowy.
- **Opis:** Nazwa modelu, skala (1/24) oraz aktualny status.
- **Background:** Tło imitujące matę do cięcia (cutting mat) z siatką.

**Empty State:** Ilustracja pustej maty modelarskiej z tekstem "Twój warsztat czeka na pierwszy model".

**CTA:** FAB (Floating Action Button) "+" do dodania nowego modelu.

**Sortowanie:** Ikonki w AppBarze pozwalające na sortowanie według daty stworzenia oraz statusu (W trakcie -> Odłożone).

---

## Design System (The Tamiya Classic)

**Kolory:**
- **Primary (Navy Blue):** `#002D56` - Główne tło AppBar i akcenty.
- **Secondary (Red):** `#E4002B` - Aktywne statusy, paski postępu, CTA.
- **Accent (Sky Blue):** `#00AEEF` - Linki, pomocnicze statusy.
- **Background:** Jasnoszara mata modelarska (`#F5F5F5`) z ciemniejszą siatką (`#E0E0E0`).

**Typografia:**
- **Nagłówki:** Sans-Serif (np. Roboto), bold, duże litery (uppercase) dla tytułów sekcji.
- **Body:** Czysty, czytelny Sans-Serif.

**Kształty:**
- **Karty:** Delikatnie zaokrąglone rogi (8-12px), białe tło, subtelny cień (elevation).
- **Ikony:** Proste, liniowe, inspirowane piktogramami z instrukcji składania modeli.

---

## Nawigacja

```
Welcome
├── "Rozpocznij jako gość" → signInAnonymously() → Onboarding
└── "Zaloguj się" → Login

Onboarding (8 stron)
├── 1. Imię modelarza
├── 2. Preview warsztatu
├── 3. Problem: Bałagan w galerii
├── 4. Solution: Twój cyfrowy build log
├── 5. Experience: Dodaj wirtualny model
├── 6. Bridge: Gotowy na pierwszy projekt?
├── 7. Minimal Setup: Twój pierwszy model (nazwa)
└── 8. → Main Screen (Home)

Main Screen (Bottom Navigation)
├── Pulpit (Home) → Aktywne budowy
├── Gablota (Showcase) → Gotowe modele → Present Model
├── Notatki (Notes) → Szybkie notatki
└── Magazyn (Stash) → Modele do zbudowania

Settings
├── Backup & Restore (Eksport Kompleksowy ZIP)
├── Zmień język (PL/EN)
├── "Wesprzyj ScaleBook" (BuyCoffee.to)
└── Wyloguj / Usuń konto
```

---

## Onboarding (FLE - First Launch Experience)

### 8 stron guided onboarding

| Strona | Cel | Zawartość |
|--------|-----|-----------|
| 1. Imię | Personalizacja | "Jak Cię nazywają w warsztacie?" |
| 2. Preview | Budowanie relacji | Podgląd estetycznej listy modeli |
| 3. Problem | Empatia | "Zdjęcia modeli giną wśród zdjęć obiadu?" |
| 4. Solution | Nadzieja | "ScaleBook to Twój dedykowany warsztat" |
| 5. Experience | Hands-on | Kliknij "Dodaj podkład", aby zobaczyć postęp |
| 6. Bridge | Motywacja | "Twoje modele zasługują na oprawę" |
| 7. Minimal Setup | Konfiguracja | Nazwa pierwszego modelu (np. Marzenie z dzieciństwa) |
| 8. (auto) | Sukces | Przejście do Home |

---

## Settings (Core)

- **Eksport Kolekcji:** Pakuje zdjęcia, JSON z projektami (z chmury i lokalnie) oraz ustawienia do jednego pliku ZIP.
- **Import Kolekcji:** Rozpakowuje ZIP i odbudowuje lokalną bazę/galerię.
- **Zmień hasło:** Szybka zmiana hasła bezpośrednio w aplikacji.
- **BuyCoffee.to:** Duży, estetyczny przycisk "Postaw kawę twórcy" (Link zewnętrzny).
- **Język:** PL/EN (automatyczna zmiana w całym UI).

---

## Auth & Tiery

### System limitów

| Tier | Limit | Jak uzyskać |
|------|-------|-------------|
| Guest | Max 3 projekty (lokalnie) | Start (Anonymously) |
| Registered | Nielimitowane projekty + Cloud Sync | Rejestracja email |

---

## Monetyzacja

**Model:** Donationware (buycoffee.to).

**Wszystkie funkcje są dostępne za darmo:**
- Nielimitowane zdjęcia na krok budowy.
- Zaawansowane szablony "Present Model".
- Brak reklam.
- Dark Mode / Premium Themes.

---

## ASO (App Store Optimization)

### Polski
- **Nazwa w Store:** ScaleBook - Build Log & Portfo
- **Podtytuł:** Warsztat każdego modelarza
- **Opis krótki:** Porządkuj budowy modeli, twórz build logi i udostępniaj piękne kolaże.

### English
- **Store Name:** ScaleBook - Model Build Log
- **Subtitle:** Your hobby, organized.
- **Short Description:** Organize your scale model builds, track progress with logs, and share stunning collages.

---

## Out of Scope (v1)

- [ ] Funkcje społecznościowe wewnątrz apki (feed innych modelarzy).
- [ ] Zaawansowana edycja zdjęć (filtry, retusz).
- [ ] Marketplace z modelami.

---

## Notatki techniczne

- **Storage:** Zdjęcia przechowywane lokalnie w folderze aplikacji (nie w galerii systemowej).
- **Backup:** `archive` package do tworzenia ZIP.
- **Collage:** `screenshot` lub `render` package do generowania obrazów z widgetów.

---

*Plik generowany automatycznie przez /start - 12 Apps Challenge*
