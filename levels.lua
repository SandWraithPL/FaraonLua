-- Definicje poziomów gry jako mapy znakowe (jak w Mario)
-- Każdy poziom to tablica z nazwą, tłem i wierszami znaków

-- Legenda znaków używanych w mapach:
-- '.' - puste miejsce (powietrze)
-- '#' - platforma/ziemia (stały grunt)
-- '^' - kolce (śmierć przy dotknięciu)
-- 'P' - pozycja startowa gracza
-- 'E' - pozycja startowa wroga (mumia)
-- 'F' - flaga/meta poziomu

local levels = {}

-- Poziom 1 - Ruiny Zewnętrzne
-- name - nazwa wyświetlana w HUD
-- bg - nazwa pliku tła (bez rozszerzenia)
-- rows - tablica wierszy, każdy wiersz to 30 znaków (30 kafelków = 960px)
levels[1] = {
    name = "Poziom 1 - Ruiny Zewnetrzne",
    bg = "level1",
    rows = {
        "..............................",
        "..............................",
        "..............................",
        "..............................",
        "..............................",
        "..............................",
        "..............................",
        "..............................",
        "....E.........E....E.....E....",
        "....##........######....##....",
        "..............................",
        "P.......E...........E.......F",
        "####..########.###..####..####",
        "####^^########^###^^####^^####",
    }
}

-- Poziom 2 - Katakumby
-- Bardziej trudny niż poziom 1, więcej wrogów i innych układów platform
levels[2] = {
    name = "Poziom 2 - Katakumby",
    bg = "level2",
    rows = {
        "..............................",
        "..............................",
        "..............................",
        "..............................",
        "..............................",
        "..............................",
        "..............................",
        "..............................",
        "....E.........E....E..........",
        "....##........#...###.........",
        "..............................",
        "P.......E...........E.......F",
        "####..########.###..####..####",
        "####^^########^###^^####^^####",
    }
}

-- Zwraca tablicę poziomów do użycia w main.lua
return levels