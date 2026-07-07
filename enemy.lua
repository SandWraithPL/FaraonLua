-- Klasa wroga (mumia) - patroluje między krawędziami platformy
local Assets = require("assets")

local Enemy = {}
Enemy.__index = Enemy

-- Tworzy nowego wroga na pozycji x,y
-- minx i maxx to granice patrolu (krawędzie platformy)
function Enemy.new(x, y, minx, maxx)
    local self = setmetatable({}, Enemy)
    self.w, self.h = 22, 24        -- wymiary wroga
    self.x, self.y = x, y
    self.vx = 60                  -- prędkość patrolu
    self.minx = minx              -- lewa granica patrolu
    self.maxx = maxx              -- prawa granica patrolu
    self.alive = true             -- czy wróg jest żywy
    return self
end

-- Aktualizuje pozycję wroga - patroluje między minx a maxx
-- Gdy dotknie krawędzi, odwraca kierunek ruchu
function Enemy:update(dt)
    if not self.alive then return end
    self.x = self.x + self.vx * dt
    if self.x < self.minx then
        self.x = self.minx
        self.vx = math.abs(self.vx)   -- idzie w prawo
    elseif self.x > self.maxx then
        self.x = self.maxx
        self.vx = -math.abs(self.vx)  -- idzie w lewo
    end
end

-- Zabija wroga - ustawia alive na false
function Enemy:kill()
    self.alive = false
end

-- Rysuje wroga jeśli jest żywy
-- Odwraca sprite'a w zależności od kierunku ruchu
function Enemy:draw()
    if not self.alive then return end
    local img = Assets.enemy
    local iw, ih = img:getWidth(), img:getHeight()
    local scale = self.h / ih * 1.9
    local ox = self.x + self.w / 2
    local oy = self.y + self.h
    -- Jeśli vx jest ujemne (idzie w lewo), odwróć sprite'a
    local sx = (self.vx < 0) and -scale or scale
    love.graphics.draw(img, ox, oy, 0, sx, scale, iw / 2, ih)
end

return Enemy