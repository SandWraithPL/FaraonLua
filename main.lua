-- Główny plik gry - tutaj jest pętla gry i zarządzanie stanami

-- Wczytujemy potrzebne moduły - assets (obrazki), player (gracz), enemy (wróg), levels (poziomy)
local Assets = require("assets")
local Player = require("player")
local Enemy = require("enemy")
local levels = require("levels")

-- TILE to rozmiar jednego kafelka w pikselach
-- MENU_W i MENU_H to wymiary okna w menu
local TILE = 32
local MENU_W, MENU_H = 1024, 683

-- Zmienne przechowujące stan gry - ile żyć ma gracz
local state = { lives = 3 }
local LIVES_START = 3

-- Indeks aktualnego poziomu, obiekt poziomu i jego wysokość w pikselach
local currentLevelIndex = 1
local level = nil
local level_pixel_height = 0

-- Obiekty w grze: gracz, lista wrogów, platformy, kolce, flaga
-- Liczniki wrogów: ogółem i zabitych
local player = nil
local enemies = {}
local solids = {}
local spikes = {}
local flag = nil
local totalEnemies = 0
local killedEnemies = 0

-- gameState mówi w którym trybie jesteśmy (menu, gra, itp.)
-- stateTimer służy do odmierzania czasu w niektórych stanach
local gameState = "menu"
local stateTimer = 0

-- Czcionki używane w różnych miejscach gry
local fontTitle, fontButton, fontHud, fontBig, fontSmall

-- Pozycja kursora myszy do obsługi przycisków
local mouseX, mouseY = 0, 0

-- Funkcja sprawdzająca czy dwa prostokąty się nakładają (kolizja)
-- ax,ay - lewy górny róg pierwszego, aw,ah - jego wymiary
-- bx,by - lewy górny róg drugiego, bw,bh - jego wymiary
local function aabbOverlap(ax,ay,aw,ah, bx,by,bw,bh)
    return ax < bx+bw and ax+aw > bx and ay < by+bh and ay+ah > by
end

-- Sprawdza czy punkt (px,py) jest wewnątrz prostokąta (x,y,w,h)
-- Używane do wykrywania czy mysz jest nad przyciskiem
local function pointInRect(px, py, x, y, w, h)
    return px >= x and px <= x+w and py >= y and py <= y+h
end

-- Rysuje przycisk na ekranie
-- x,y,w,h - pozycja i wymiary, label - tekst, hovered - czy mysz jest nad nim
-- hovered zmienia kolor przycisku na jaśniejszy
local function drawButton(x, y, w, h, label, hovered)
    if hovered then
        love.graphics.setColor(0.85, 0.65, 0.20, 0.6)
    else
        love.graphics.setColor(0.55, 0.38, 0.14, 0.5)
    end
    love.graphics.rectangle("fill", x, y, w, h, 8, 8)
    love.graphics.setColor(0.95, 0.85, 0.55, 0.7)
    love.graphics.rectangle("line", x, y, w, h, 8, 8)

    love.graphics.setFont(fontButton)
    if hovered then
        love.graphics.setColor(0.15, 0.08, 0.02, 1)
    else
        love.graphics.setColor(0.98, 0.93, 0.78, 1)
    end
    love.graphics.printf(label, x, y + h/2 - fontButton:getHeight()/2, w, "center")
    love.graphics.setColor(1,1,1,1)
end

-- Zwraca listę przycisków które powinny być widoczne w danym stanie gry
-- Pozycje są przeliczane co klatkę bo zależą od rozmiaru okna
local function getButtons()
    local w, h = love.graphics.getDimensions()
    local btns = {}
    -- W menu są przyciski GRAJ i STEROWANIE
    if gameState == "menu" then
        local bw, bh = 260, 56
        local bx = 180
        local by = h * 0.55
        table.insert(btns, {id="play", x=bx, y=by, w=bw, h=bh, label="GRAJ"})
        table.insert(btns, {id="controls", x=bx, y=by + bh + 18, w=bw, h=bh, label="STEROWANIE"})
    -- W ekranie sterowania też są te same przyciski
    elseif gameState == "controls" then
        local bw, bh = 260, 56
        local bx = 180
        local by = h * 0.55
        table.insert(btns, {id="play", x=bx, y=by, w=bw, h=bh, label="GRAJ"})
        table.insert(btns, {id="controls", x=bx, y=by + bh + 18, w=bw, h=bh, label="STEROWANIE"})
    -- Po przegranej lub wygranej są przyciski restart i menu
    elseif gameState == "gameover" or gameState == "win" then
        local bw, bh = 240, 52
        local bx = w/2 - bw/2
        table.insert(btns, {id="restart", x=bx, y=h/2 + 40, w=bw, h=bh, label="ZAGRAJ PONOWNIE"})
        table.insert(btns, {id="menu", x=bx, y=h/2 + 40 + bh + 14, w=bw, h=bh, label="MENU GLOWNE"})
    end
    return btns
end

-- Aktualizuje pozycję myszy - jeśli podano x,y to z nich, inaczej z systemu
local function updateMousePos(x, y)
    if x and y then
        mouseX, mouseY = x, y
    else
        mouseX, mouseY = love.mouse.getPosition()
    end
end

-- Przełącza grę w tryb menu i ustawia rozmiar okna
local function showMenu()
    gameState = "menu"
    love.window.setMode(MENU_W, MENU_H, {resizable=false})
end

-- Wczytuje poziom o podanym indeksie i parsuje mapę znakową
-- Tworzy platformy, kolce, wrogów i flagę na podstawie znaków w mapie
local function loadLevel(index)
    level = levels[index]
    solids = {}
    spikes = {}
    enemies = {}
    flag = nil
    totalEnemies = 0
    killedEnemies = 0

    -- Pobieramy wymiary poziomu z mapy
    local rows = level.rows
    local height = #rows
    local width = #rows[1]
    level_pixel_height = height * TILE

    -- Ustawiamy okno gry na rozmiar poziomu
    love.window.setMode(width*TILE, height*TILE, {resizable=false})

    local playerX, playerY = 0, 0

    -- Przechodzimy przez każdy znak w mapie i tworzymy odpowiednie obiekty
    for r = 1, height do
        local rowStr = rows[r]
        for c = 1, width do
            local ch = rowStr:sub(c,c)
            local px = (c-1)*TILE
            local py = (r-1)*TILE
            -- # to platforma (ziemia)
            if ch == "#" then
                table.insert(solids, {x=px, y=py, w=TILE, h=TILE})
            -- ^ to kolce (smierc)
            elseif ch == "^" then
                table.insert(spikes, {x=px, y=py+TILE*0.4, w=TILE, h=TILE*0.6})
            -- P to pozycja startowa gracza
            elseif ch == "P" then
                playerX, playerY = px, py + TILE - 28
            -- E to wróg (mumia)
            elseif ch == "E" then
                -- Sprawdzamy czy wróg stoi na podłożu
                local groundY = py + TILE
                local hasGround = false
                if r < height then
                    local below = rows[r+1]:sub(c,c)
                    if below == "#" then
                        hasGround = true
                    end
                end
                
                -- Jeśli nie ma podłoża bezpośrednio pod nim, szukamy niżej
                if not hasGround then
                    for rr = r+1, height do
                        local rowBelow = rows[rr]:sub(c,c)
                        if rowBelow == "#" then
                            groundY = (rr-1)*TILE
                            hasGround = true
                            break
                        end
                    end
                end
                
                -- Jeśli znaleźliśmy podłoże, tworzymy wroga
                if hasGround then
                    local eh = 24
                    -- Zasięg patrolu wroga na platformie
                    local minx = math.max(0, px - TILE)
                    local maxx = math.min((width-1)*TILE, px + TILE*2)
                    
                    -- Znajdujemy krawędzie platformy żeby wróg nie spadł
                    if r < height then
                        local groundRow = rows[r+1]
                        if groundRow then
                            local left = c
                            while left > 1 and groundRow:sub(left-1, left-1) == "#" do
                                left = left - 1
                            end
                            local right = c
                            while right < width and groundRow:sub(right+1, right+1) == "#" do
                                right = right + 1
                            end
                            minx = (left-1)*TILE
                            maxx = (right-1)*TILE + TILE - 22
                        end
                    end
                    
                    table.insert(enemies, Enemy.new(px, groundY - eh, minx, maxx))
                    totalEnemies = totalEnemies + 1
                end
            -- F to flaga (meta poziomu)
            elseif ch == "F" then
                -- Sprawdzamy czy pod flagą jest podłoże
                local hasGround = false
                if r < height then
                    local below = rows[r+1]:sub(c,c)
                    if below == "#" then
                        hasGround = true
                    end
                end
                if hasGround then
                    flag = {x = px, y = py, w = TILE, h = TILE}
                else
                    -- Jeśli flaga jest w powietrzu, szukamy podłoża poniżej
                    local groundY = py
                    for rr = r+1, height do
                        local rowBelow = rows[rr]:sub(c,c)
                        if rowBelow == "#" then
                            groundY = (rr-1)*TILE
                            break
                        end
                    end
                    flag = {x = px, y = groundY - TILE, w = TILE, h = TILE}
                end
            end
        end
    end

    -- Tworzymy gracza na pozycji startowej
    player = Player.new(playerX, playerY)

    gameState = "playing"
    stateTimer = 0
end

-- Resetuje grę od początku - wraca do poziomu 1 i przywraca życia
local function resetGame()
    currentLevelIndex = 1
    state.lives = LIVES_START
    loadLevel(currentLevelIndex)
end

-- Funkcja wywoływana na początku gry - ładuje assets i czcionki
function love.load()
    Assets.load()
    fontTitle  = love.graphics.newFont(34)
    fontButton = love.graphics.newFont(20)
    fontHud    = love.graphics.newFont(14)
    fontBig    = love.graphics.newFont(28)
    fontSmall  = love.graphics.newFont(15)
    showMenu()
end

-- Zabija gracza - odejmuje życie i kończy grę albo resetuje poziom
-- Jeśli gracz ma nieśmiertelność (invuln), to nie ginie
local function killPlayer()
    if player.invuln > 0 then return end
    state.lives = state.lives - 1
    if state.lives <= 0 then
        gameState = "gameover"
        stateTimer = 0
    else
        loadLevel(currentLevelIndex)
    end
end

-- Główna pętla aktualizacji gry - wywoływana co klatkę
-- dt to czas od ostatniej klatki w sekundach
function love.update(dt)
    -- W menu i sterowaniu tylko aktualizujemy mysz
    if gameState == "menu" or gameState == "controls" then
        updateMousePos()
        return
    end

    -- Po przegranej/wygranej też tylko mysz i timer
    if gameState == "gameover" or gameState == "win" then
        updateMousePos()
        stateTimer = stateTimer + dt
        return
    end

    -- Po ukończeniu poziomu czekamy chwilę i ładujemy następny
    if gameState == "levelclear" then
        stateTimer = stateTimer + dt
        if stateTimer > 0.9 then
            currentLevelIndex = currentLevelIndex + 1
            if currentLevelIndex > #levels then
                gameState = "win"
                stateTimer = 0
            else
                loadLevel(currentLevelIndex)
            end
        end
        return
    end

    -- Aktualizujemy gracza i sprawdzamy czy nie spadł poza mapę
    player:update(dt, solids)

    if player.y > level_pixel_height then
        killPlayer()
        return
    end

    -- Sprawdzamy kolizję z kolcami - jeśli dotknie to ginie
    for _, sp in ipairs(spikes) do
        if aabbOverlap(player.x, player.y, player.w, player.h, sp.x, sp.y, sp.w, sp.h) then
            killPlayer()
            return
        end
    end

    -- Sprawdzamy czy gracz dotknął flagi - jeśli tak to poziom ukończony
    if flag and aabbOverlap(player.x, player.y, player.w, player.h, flag.x, flag.y, flag.w, flag.h) then
        gameState = "levelclear"
        stateTimer = 0
        return
    end

    -- Aktualizujemy wrogów i sprawdzamy kolizję z graczem
    -- Jeśli gracz nie atakuje i dotknie wroga to ginie
    for _, e in ipairs(enemies) do
        e:update(dt)
        if e.alive and not player.attacking and aabbOverlap(player.x, player.y, player.w, player.h, e.x, e.y, e.w, e.h) then
            killPlayer()
            return
        end
    end

    -- Jeśli gracz atakuje, sprawdzamy czy trafił wroga
    local ax, ay, aw, ah = player:getAttackHitbox()
    if ax then
        for _, e in ipairs(enemies) do
            if e.alive and aabbOverlap(ax, ay, aw, ah, e.x, e.y, e.w, e.h) then
                e:kill()
                killedEnemies = killedEnemies + 1
            end
        end
    end
end

-- Wykonuje akcję przycisku na podstawie jego id
local function activateButton(id)
    if id == "play" then
        resetGame()
    elseif id == "controls" then
        gameState = "controls"
    elseif id == "back" then
        showMenu()
    elseif id == "restart" then
        resetGame()
    elseif id == "menu" then
        showMenu()
    end
end

-- Obsługa klawiatury - różne klawisze w zależności od stanu gry
function love.keypressed(key)
    if gameState == "menu" then
        -- Enter/space zaczyna grę, C pokazuje sterowanie
        if key == "return" or key == "space" or key == "kpenter" then
            resetGame()
        elseif key == "c" then
            gameState = "controls"
        end
    elseif gameState == "controls" then
        -- Escape wraca do menu
        if key == "escape" or key == "return" or key == "backspace" then
            showMenu()
        end
    elseif gameState == "playing" then
        -- Space skacze, J atakuje, R restartuje poziom, ESC do menu
        if key == "space" then
            player:jump()
        elseif key == "j" then
            player:startAttack()
        elseif key == "r" then
            loadLevel(currentLevelIndex)
        elseif key == "escape" then
            showMenu()
        end
    elseif gameState == "gameover" or gameState == "win" then
        -- R lub Enter restartuje grę, ESC do menu
        if key == "r" or key == "return" then
            resetGame()
        elseif key == "escape" then
            showMenu()
        end
    end
end

-- Aktualizuje pozycję myszy gdy się porusza
function love.mousemoved(x, y)
    updateMousePos(x, y)
end

-- Obsługa kliknięcia myszy - sprawdza czy kliknięto w przycisk
-- button ~= 1 oznacza że nie kliknięto lewym przyciskiem
function love.mousepressed(x, y, button)
    if button ~= 1 then return end
    updateMousePos(x, y)
    for _, b in ipairs(getButtons()) do
        if pointInRect(mouseX, mouseY, b.x, b.y, b.w, b.h) then
            activateButton(b.id)
            return
        end
    end
end

-- Rysuje tło poziomu - skaluje obrazek do rozmiaru okna
local function drawBackground()
    local w, h = love.graphics.getDimensions()
    local img = level and Assets.backgrounds[level.bg]
    if img then
        local iw, ih = img:getWidth(), img:getHeight()
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(img, 0, 0, 0, w/iw, h/ih)
    else
        -- Jeśli nie ma tła, rysujemy ciemne tło
        love.graphics.setColor(0.1, 0.1, 0.15, 1)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end
    love.graphics.setColor(1,1,1,1)
end

-- Rysuje wszystkie platformy (ziemię) używając tekstury
local function drawSolids()
    local img = Assets.ground
    local iw, ih = img:getWidth(), img:getHeight()
    local sx, sy = TILE/iw, TILE/ih
    for _, s in ipairs(solids) do
        love.graphics.draw(img, s.x, s.y, 0, sx, sy)
    end
end

-- Rysuje wszystkie kolce - skaluje wysokość do rozmiaru kolca
local function drawSpikes()
    local img = Assets.spikes
    local iw, ih = img:getWidth(), img:getHeight()
    for _, sp in ipairs(spikes) do
        local sx = TILE/iw
        local sy = sp.h/ih
        love.graphics.draw(img, sp.x, sp.y, 0, sx, sy)
    end
end

-- Rysuje flagę (metę) na jej pozycji
local function drawFlag()
    if not flag then return end
    local img = Assets.flag
    local iw, ih = img:getWidth(), img:getHeight()
    local scale = flag.h / ih
    love.graphics.draw(img, flag.x + flag.w/2, flag.y + flag.h, 0, scale, scale, iw/2, ih)
end

-- Rysuje HUD (interfejs) - nazwa poziomu, życia, wrogowie
-- Rozmieszczone w rogach ekranu w małych prostokątach
local function drawHUD()
    local w, h = love.graphics.getDimensions()
    love.graphics.setFont(fontHud)
    
    -- Nazwa poziomu w lewym rogu
    love.graphics.setColor(0,0,0,0.4)
    love.graphics.rectangle("fill", 8, 8, 240, 24, 4)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(level.name, 16, 14)
    
    -- Życia w prawym rogu
    love.graphics.setColor(0,0,0,0.4)
    love.graphics.rectangle("fill", w - 120, 8, 100, 24, 4)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Zycia: " .. tostring(state.lives), w - 110, 14)
    
    -- Wrogowie w lewym dolnym rogu
    love.graphics.setColor(0,0,0,0.4)
    love.graphics.rectangle("fill", 8, h - 32, 160, 24, 4)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Wrogowie: " .. killedEnemies .. "/" .. totalEnemies, 16, h - 26)
end

-- Rysuje menu główne - tło i przyciski
local function drawMenu()
    local w, h = love.graphics.getDimensions()
    local img = Assets.menuBg
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(img, 0, 0, 0, w/img:getWidth(), h/img:getHeight())

    for _, b in ipairs(getButtons()) do
        local hovered = pointInRect(mouseX, mouseY, b.x, b.y, b.w, b.h)
        drawButton(b.x, b.y, b.w, b.h, b.label, hovered)
    end
end

-- Rysuje ekran sterowania - tło, instrukcje i przyciski
-- Panel z instrukcjami jest po prawej stronie
local function drawControls()
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(1,1,1,1)
    local img = Assets.menuBg
    love.graphics.draw(img, 0, 0, 0, w/img:getWidth(), h/img:getHeight())

    local panelW, panelH = math.min(380, w*0.35), math.min(480, h*0.8)
    local px, py = w - panelW - 40, h/2 - panelH/2

    love.graphics.setFont(fontBig)
    love.graphics.setColor(0.3, 0.15, 0.05, 1)
    love.graphics.printf("STEROWANIE", px, py + 24, panelW, "center")

    love.graphics.setFont(fontSmall)
    love.graphics.setColor(0.2, 0.12, 0.06, 1)
    local lines = {
        "  A / D  lub  strzalki   -  ruch",
        "  SPACJA                    -  skok",
        "  J                             -  atak",
        "  R                            -  restart",
        "  ESC                        -  menu",
        "",
        "  Zasady:",
        "  • 3 zycia",
        "  • Unikaj kolcow i wrogow",
        "  • Dotknij flagi",
    }
    local ly = py + 70
    for _, line in ipairs(lines) do
        love.graphics.printf(line, px + 25, ly, panelW - 50, "left")
        ly = ly + 24
    end

    for _, b in ipairs(getButtons()) do
        local hovered = pointInRect(mouseX, mouseY, b.x, b.y, b.w, b.h)
        drawButton(b.x, b.y, b.w, b.h, b.label, hovered)
    end
end

-- Rysuje komunikat nakładki (gameover/win) - ciemne tło, tekst i przyciski
local function drawOverlayMessage(title, subtitle, color)
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0,0,0,0.6)
    love.graphics.rectangle("fill", 0, 0, w, h)

    love.graphics.setFont(fontBig)
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.printf(title, 0, h/2 - 60, w, "center")

    if subtitle then
        love.graphics.setFont(fontSmall)
        love.graphics.setColor(0.95, 0.93, 0.88, 1)
        love.graphics.printf(subtitle, 0, h/2 - 14, w, "center")
    end

    for _, b in ipairs(getButtons()) do
        local hovered = pointInRect(mouseX, mouseY, b.x, b.y, b.w, b.h)
        drawButton(b.x, b.y, b.w, b.h, b.label, hovered)
    end
end

-- Główna funkcja rysowania - wywoływana co klatkę
-- Rysuje odpowiednie elementy w zależności od stanu gry
function love.draw()
    if gameState == "menu" then
        drawMenu()
        return
    elseif gameState == "controls" then
        drawControls()
        return
    end

    -- Podczas gry rysujemy wszystko po kolei
    drawBackground()
    drawSolids()
    drawSpikes()
    drawFlag()
    for _, e in ipairs(enemies) do e:draw() end
    player:draw()
    drawHUD()

    -- Komunikaty specjalne w zależności od stanu
    if gameState == "levelclear" then
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setFont(fontBig)
        love.graphics.setColor(1,1,0.6,1)
        love.graphics.printf("Poziom ukonczony!", 0, love.graphics.getHeight()/2-16, love.graphics.getWidth(), "center")
    elseif gameState == "gameover" then
        drawOverlayMessage("KONIEC GRY", "Nacisnij R aby zaczac od nowa", {1,0.3,0.3})
    elseif gameState == "win" then
        drawOverlayMessage("Gratulacje! Zdobyles skarb faraona!", "Nacisnij R aby zagrac ponownie", {1,0.9,0.3})
    end
end