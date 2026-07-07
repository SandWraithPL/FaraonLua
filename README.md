# 🏺 Zaginiony Skarb Faraona

![Platformer Game](https://img.shields.io/badge/genre-Platformer-blue)
![LOVE2D](https://img.shields.io/badge/engine-LOVE2D-orange)
![Lua](https://img.shields.io/badge/language-Lua-blueviolet)
![License](https://img.shields.io/badge/license-MIT-green)

Klasyczna platformówka 2D inspirowana grami Mario. Wciel się w poszukiwacza skarbów i przemierzaj egipskie grobowce, omijając pułapki i walcząc z mumiami, aby odnaleźć zaginiony skarb faraona.

## 🎮 O Grze

**Zaginiony Skarb Faraona** to prosta, ale wciągająca platformówka 2D stworzona w ramach projektu studenckiego. Gracz musi przejść przez dwa poziomy - Ruiny Zewnętrzne i Katakumby - unikając kolców, przeskakując nad dziurami i pokonując strażników grobowca.

### ✨ Cechy Gry

- **2 poziomy** o rosnącym poziomie trudności
- **System życia** - 3 szanse na ukończenie gry
- **Walka** - atakuj wrogów (mumie) aby ich pokonać
- **Różnorodne przeszkody** - kolce, dziury, wrogowie
- **Pixel art** - styl graficzny inspirowany klasycznymi grami
- **Intuicyjne sterowanie** - klawiatura i obsługa myszy
- **System animacji** - chód, skok, atak

## 🛠️ Użyte Technologie

- **LOVE2D** (v0.11+) - framework do tworzenia gier 2D w Lua
- **Lua** - język programowania
- **Pixel Art** - własna grafika w stylu retro

## 📋 Wymagania Systemowe

- System operacyjny: Windows, Linux lub macOS
- **LOVE2D** (v0.11 lub nowszy) - [pobierz tutaj](https://love2d.org/)
- 50 MB wolnego miejsca na dysku

## 🚀 Instalacja

### Krok 1: Zainstaluj LOVE2D

Pobierz i zainstaluj LOVE2D ze strony oficjalnej: [https://love2d.org/](https://love2d.org/)

### Krok 2: Pobierz grę

Sklonuj repozytorium lub pobierz pliki ZIP:

```bash
git clone https://github.com/twoj-uzytkownik/gra-lua-faraon.git
cd gra-lua-faraon
```

### Krok 3: Uruchom grę

**Windows:**
- Kliknij dwukrotnie na plik `.love` (jeśli jest spakowany)
- Lub przeciągnij folder gry na ikonę LOVE2D

**Linux:**
```bash
love gra-lua-faraon
```

**macOS:**
- Otwórz aplikację LOVE2D
- Przeciągnij folder gry na ikonę aplikacji

## 🎯 Jak Grać

### Sterowanie

| Klawisz | Akcja |
|---------|-------|
| `A` / `D` lub `←` / `→` | Ruch w lewo/prawo |
| `SPACJA` | Skok |
| `J` | Atak |
| `R` | Restart poziomu |
| `ESC` | Powrót do menu |

### Zasady Gry

1. **Celem gry** jest dotknięcie flagi na końcu każdego poziomu
2. Masz **3 życia** - stracisz jedno gdy:
   - Spadniesz w dziurę
   - Dotkniesz kolców
   - Zostaniesz zaatakowany przez wroga
3. Pokonuj wrogów **atakując** (klawisz `J`)
4. Po utracie wszystkich żyć gra się kończy
5. Ukończ oba poziomy aby wygrać!

## 📁 Struktura Projektu

```
gra-lua-faraon/
├── main.lua          # Główna pętla gry, zarządzanie stanami
├── player.lua        # Klasa gracza - ruch, skok, atak
├── enemy.lua         # Klasa wroga - patrolowanie
├── levels.lua        # Definicje poziomów (mapy znakowe)
├── assets.lua        # Wczytywanie grafiki
├── conf.lua          # Konfiguracja okna gry
├── assets/           # Folder z grafiką
│   ├── player_*.png   # Sprite'y gracza
│   ├── enemy.png      # Sprite wroga
│   ├── ground.png     # Tekstura ziemi
│   ├── spikes.png     # Tekstura kolców
│   ├── flag.png       # Tekstura flagi
│   ├── bg_level*.png  # Tła poziomów
│   └── menu_bg.png    # Tło menu
└── README.md          # Ten plik
```

## 🎨 Poziomy

### Poziom 1: Ruiny Zewnętrzne
Wprowadzenie do gry - prosty poziom z podstawowymi przeszkodami i wrogami. Naucz się sterowania i mechaniki gry.

### Poziom 2: Katakumby
Trudniejszy poziom z bardziej skomplikowanym układem platform, większą liczbą wrogów i wymagającymi skokami.

## 🐛 Znane Problemy

- Brak

## 🤝 Współpraca

Wkład w rozwój gry jest mile widziany! Jeśli chcesz zgłosić błąd lub zaproponować nową funkcję:

1. Otwórz issue na GitHub
2. Opisz problem lub pomysł
3. Dodaj zrzuty ekranu jeśli to możliwe

## 📄 Licencja

Ten projekt jest dostępny na licencji MIT. Zobacz plik LICENSE dla szczegółów.

## 👨‍💻 Autor

Projekt stworzony w ramach zajęć studenckich.

---

**Miłej gry!** 🎮
