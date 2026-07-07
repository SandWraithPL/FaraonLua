-- Klasa gracza - obsługuje ruch, skok, atak, kolizje i rysowanie
local Assets = require("assets")

local Player = {}
Player.__index = Player

-- Stałe wartości dla fizyki i mechaniki gracza
local MOVE_SPEED = 150      -- prędkość ruchu
local JUMP_VELOCITY = -450  -- siła skoku (ujemna bo w górę)
local GRAVITY = 950          -- siła grawitacji
local ATTACK_DURATION = 0.16 -- jak długo trwa atak
local ATTACK_COOLDOWN = 0.28 -- czas między atakami
local ATTACK_RANGE = 26      -- zasięg ataku w pikselach
local RESPAWN_INVULN = 1.0   -- czas nieśmiertelności po respawnie

-- Funkcja pomocnicza do sprawdzania kolizji prostokątów
local function aabbOverlap(ax, ay, aw, ah, bx, by, bw, bh)
    return ax < bx + bw and ax + aw > bx and ay < by + bh and ay + ah > by
end

-- Tworzy nowego gracza na pozycji x,y
-- Inicjalizuje wszystkie zmienne stanu gracza
function Player.new(x, y)
    local self = setmetatable({}, Player)
    self.x, self.y = x, y
    self.w, self.h = 22, 28        -- wymiary gracza
    self.vx, self.vy = 0, 0        -- prędkość w osi x i y
    self.onGround = false          -- czy stoi na ziemi
    self.facing = 1                -- w którą stronę patrzy (1=prawo, -1=lewo)
    self.attacking = false         -- czy aktualnie atakuje
    self.attackTimer = 0           -- timer trwania ataku
    self.attackCooldown = 0        -- cooldown między atakami
    self.invuln = RESPAWN_INVULN   -- czas nieśmiertelności
    self.animTimer = 0             -- timer animacji
    self.animFrame = 1             -- klatka animacji
    return self
end

-- Zwraca zasięg ataku gracza
function Player:attackRange()
    return ATTACK_RANGE
end

-- Rozpoczyna atak jeśli nie ma cooldownu
function Player:startAttack()
    if self.attackCooldown <= 0 then
        self.attacking = true
        self.attackTimer = ATTACK_DURATION
        self.attackCooldown = ATTACK_COOLDOWN
    end
end

-- Skacze jeśli gracz stoi na ziemi
function Player:jump()
    if self.onGround then
        self.vy = JUMP_VELOCITY
    end
end

-- Przesuwa obiekt o dx,dy i rozwiązuje kolizje z platformami
-- Najpierw przesuwa w poziomie i sprawdza kolizje boczne
-- Potem przesuwa w pionie i sprawdza kolizje pionowe
-- Zwraca true jeśli obiekt stoi na ziemi
local function moveAndCollide(entity, dx, dy, solids)
    entity.x = entity.x + dx
    for _, s in ipairs(solids) do
        if aabbOverlap(entity.x, entity.y, entity.w, entity.h, s.x, s.y, s.w, s.h) then
            if dx > 0 then
                entity.x = s.x - entity.w
            elseif dx < 0 then
                entity.x = s.x + s.w
            end
        end
    end

    entity.y = entity.y + dy
    local grounded = false
    for _, s in ipairs(solids) do
        if aabbOverlap(entity.x, entity.y, entity.w, entity.h, s.x, s.y, s.w, s.h) then
            if dy > 0 then
                entity.y = s.y - entity.h
                grounded = true
            elseif dy < 0 then
                entity.y = s.y + s.h
            end
            entity.vy = 0
        end
    end
    return grounded
end

-- Aktualizuje stan gracza co klatkę
-- Obsługuje input, fizykę, kolizje i animację
function Player:update(dt, solids)
    -- Zmniejsza timery nieśmiertelności i ataku
    if self.invuln > 0 then self.invuln = self.invuln - dt end
    if self.attackCooldown > 0 then self.attackCooldown = self.attackCooldown - dt end
    if self.attacking then
        self.attackTimer = self.attackTimer - dt
        if self.attackTimer <= 0 then self.attacking = false end
    end

    -- Obsługa ruchu w lewo/prawo
    self.vx = 0
    if love.keyboard.isDown("a", "left") then
        self.vx = -MOVE_SPEED
        self.facing = -1
    end
    if love.keyboard.isDown("d", "right") then
        self.vx = MOVE_SPEED
        self.facing = 1
    end

    -- Fizyka grawitacji
    self.vy = self.vy + GRAVITY * dt

    -- Przesunięcie i kolizje
    self.onGround = moveAndCollide(self, self.vx * dt, self.vy * dt, solids)

    -- Animacja chodu - przełączanie między dwoma klatkami
    if self.vx ~= 0 and self.onGround and not self.attacking then
        self.animTimer = self.animTimer + dt
        if self.animTimer >= 0.12 then
            self.animTimer = self.animTimer - 0.12
            self.animFrame = 3 - self.animFrame
        end
    else
        self.animFrame = 1
        self.animTimer = 0
    end
end

-- Zwraca prostokąt ataku przed graczем
-- Jeśli gracz nie atakuje zwraca nil
function Player:getAttackHitbox()
    if not self.attacking then return nil end
    local ax
    -- Pozycja hitboxu zależy od tego w którą stronę patrzy gracz
    if self.facing > 0 then
        ax = self.x + self.w
    else
        ax = self.x - ATTACK_RANGE
    end
    return ax, self.y, ATTACK_RANGE, self.h
end

-- Rysuje gracza z odpowiednim sprite'em w zależności od stanu
-- Jeśli ma nieśmiertelność to miga (nie rysuje co drugą klatkę)
function Player:draw()
    if self.invuln > 0 and math.floor(self.invuln * 10) % 2 == 0 then
        return
    end

    -- Wybór sprite'a w zależności od akcji gracza
    local img
    if self.attacking then
        img = Assets.player.attack
    elseif not self.onGround then
        img = Assets.player.jump
    elseif self.vx ~= 0 then
        img = (self.animFrame == 1) and Assets.player.walk1 or Assets.player.walk2
    else
        img = Assets.player.idle
    end

    -- Skalowanie i pozycjonowanie sprite'a
    local iw, ih = img:getWidth(), img:getHeight()
    local scale = self.h / ih * 1.9
    local ox = self.x + self.w / 2
    local oy = self.y + self.h

    -- Odwrócenie sprite'a jeśli patrzy w lewo
    local sx = (self.facing < 0) and -scale or scale
    love.graphics.draw(img, ox, oy, 0, sx, scale, iw / 2, ih)
end

return Player