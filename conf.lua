-- Plik konfiguracyjny LOVE2D - ustawienia okna gry
-- Wywoływany przed main.lua, ustawia tytuł i wymiary okna

function love.conf(t)
    t.title = "Zaginiony Skarb Faraona"  -- tytuł okna gry
    t.window.width = 960               -- szerokość okna w pikselach
    t.window.height = 480              -- wysokość okna w pikselach
    t.window.resizable = false         -- okno nie może być zmieniane przez gracza
    t.console = false                  -- ukrywa konsolę debugową
end