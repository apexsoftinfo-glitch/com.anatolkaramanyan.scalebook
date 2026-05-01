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
- *"Eksportować historię budowy do social mediów (kolaże)"*
- *"Projekt non-profit, wspierany wyłącznie przez serwis buycoffee.to"*
- *"Wyłącznie lokalne ZIP ze wszystkimi zdjęciami i danymi. W bazach tylko konta użytkowników."*

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
| Home | Lista/Grid modeli (W budowie / Gotowe) | CORE |
| Model Detail | Historia budowy + Galeria końcowa | CORE |
| Add/Edit Model | Formularz modelu (Nazwa, Skala, Producent) | CORE |
| Add Build Step | Dodawanie zdjęć + notatek do logu | CORE |
| Collage Preview | Generowanie i podgląd kolażu do eksportu | CORE |
| Settings | Backup ZIP, Język, BuyCoffee link | CORE |
| Login / Register | Opcjonalna synchronizacja konta | AUTH |

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
└── 8. → Home (z dodanym pierwszym modelem)

Home
├── Tap na model → Model Detail
├── FAB → Add Model
└── Menu (Ikona profilu/śrubki) → Settings

Model Detail
├── Tab 1: Build Log (chronologiczna lista kroków)
├── Tab 2: Gallery (zdjęcia gotowego modelu)
└── FAB/CTA → Add Build Step

Settings
├── Backup & Restore (Export/Import ZIP)
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

- **Export Kolekcji:** Pakuje zdjęcia i JSON z opisami do jednego pliku ZIP (lokalnie).
- **Import Kolekcji:** Rozpakowuje ZIP i odbudowuje lokalną bazę/galerię.
- **BuyCoffee.to:** Duży, estetyczny przycisk "Postaw kawę twórcy" (Link zewnętrzny).
- **Język:** PL/EN.

---

## Auth & Tiery

### System limitów

**Projekt non-profit: Brak twardych limitów ilościowych.**

| Tier | Limit | Jak uzyskać |
|------|-------|-------------|
| Guest | Pełna funkcjonalność (lokalnie) | Start (Anonymously) |
| Registered | Sync konta (jeśli dodamy) | Rejestracja email |
| Pro | Brak (ScaleBook jest darmowy) | — |

---

## Monetyzacja

**Model:** Donationware (buycoffee.to).

**Pro Features (jako podziękowanie za wsparcie lub po prostu dostępne):**
- Nielimitowane zdjęcia na krok budowy.
- Zaawansowane szablony kolaży (więcej układów).
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

- [ ] Automatyczny sync w chmurze (tylko ZIP backup).
- [ ] Funkcje społecznościowe wewnątrz apki (feed innych modelarzy).
- [ ] Zaawansowana edycja zdjęć (filtry, retusz).

---

## Notatki techniczne

- **Storage:** Zdjęcia przechowywane lokalnie w folderze aplikacji (nie w galerii systemowej).
- **Backup:** `archive` package do tworzenia ZIP.
- **Collage:** `screenshot` lub `render` package do generowania obrazów z widgetów.

---

*Plik generowany automatycznie przez /start - 12 Apps Challenge*
