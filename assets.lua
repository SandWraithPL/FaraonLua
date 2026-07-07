-- Moduł do wczytywania wszystkich obrazków (sprite'ów) z folderu assets/
-- Wszystkie obrazki są ładowane raz na początku gry i przechowywane w tabeli Assets
-- Dzięki temu reszta gry może łatwo korzystać z grafiki

local Assets = {}

-- Wczytuje wszystkie obrazki i ustawia filtr graficzny
-- Filtr "nearest" sprawia że piksele są ostre (pixel-art style)
function Assets.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Sprite'y gracza dla różnych animacji
    Assets.player = {
        idle  = love.graphics.newImage("assets/player_idle.png"),   -- gracz stoi
        walk1 = love.graphics.newImage("assets/player_walk1.png"),  -- chód klatka 1
        walk2 = love.graphics.newImage("assets/player_walk2.png"),  -- chód klatka 2
        jump  = love.graphics.newImage("assets/player_jump.png"),   -- skok
        attack = love.graphics.newImage("assets/player_attack.png"), -- atak
    }
    -- Sprite wroga (mumia)
    Assets.enemy  = love.graphics.newImage("assets/enemy.png")
    -- Tekstury otoczenia
    Assets.ground = love.graphics.newImage("assets/ground.png")   -- platforma/ziemia
    Assets.spikes = love.graphics.newImage("assets/spikes.png")   -- kolce
    Assets.flag   = love.graphics.newImage("assets/flag.png")     -- flaga/meta

    -- Tła poziomów
    Assets.backgrounds = {
        level1 = love.graphics.newImage("assets/bg_level1.png"),  -- tło poziomu 1
        level2 = love.graphics.newImage("assets/bg_level2.png"),  -- tło poziomu 2
    }
    -- Tło menu
    Assets.menuBg = love.graphics.newImage("assets/menu_bg.png")
    -- menu_bg2 nie istnieje - używamy menu_bg jako fallback
    Assets.menuBg2 = Assets.menuBg
end

-- Zwraca tabelę Assets do użycia w innych plikach
return Assets