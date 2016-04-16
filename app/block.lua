local block = class()

block.colors = { 'orange', 'purple', 'green' }
block.images = {
  orange = art.orangeblock,
  purple = art.purpleblock,
  green = art.greenblock
}

block.speed = 600
block.delay = 1

function block:init(color)
  self.rx = love.math.random(app.region.x1, app.region.x2 - 1) * app.grid.size
  self.ry = love.math.random(app.region.y1, app.region.y2 - 1) * app.grid.size

  self.angle = math.floor(love.math.random() * 2 * math.pi / (math.pi / 2)) * (math.pi / 2)
  self.timer = self.delay
  self.color = color
  self.wasStatic = false
  self.originalAngle = self.angle

  self.scale = 0
  lib.flux.to(self, .3, { scale = 1 }):ease('backout')

  self.static = false
end

function block:update(dt)
  if self.static then return end

  self.timer = math.max(self.timer - dt, 0)

  self.angle = self.originalAngle - app.grid.angle

  if self.timer <= 0 and not app.grid.animating then
    if wasStatic then
      self.x = self.x + math.dx(self.speed * dt, self.angle)
      self.y = self.y + math.dy(self.speed * dt, self.angle)
    else
      self.x = self.x + math.dx(self.speed * dt, self.angle)
      self.y = self.y + math.dy(self.speed * dt, self.angle)
    end

    local hasCollision = false

    if #app.grid.world:queryRect(self.x, self.y, app.grid.size, app.grid.size) > 0 then
      hasCollision = true
    end

    if self:isEscaped() or hasCollision then
      self.x = math.round(self.x / app.grid.size) * app.grid.size
      self.y = math.round(self.y / app.grid.size) * app.grid.size

      self.static = true
      self.wasStatic = true
      app.grid.world:add(self, self.x + 4, self.y + 4, app.grid.size - 8, app.grid.size - 8)
      self.gridX = math.round(self.x / app.grid.size)
      self.gridY = math.round(self.y / app.grid.size)
      app.grid:setBlock(self.gridX, self.gridY, self)
      app.blocks:matchPattern()
    end
  else
    self:setPosition()
  end
end

function block:draw()
  local gridSize = app.grid.size

  if not self.static then
    g.push()
    g.translate((self.x + gridSize / 2), (self.y + gridSize / 2))
    g.rotate(-app.grid.angle)
    g.translate(-(self.x + gridSize / 2), -(self.y + gridSize / 2))
  end

  local size = app.grid.size * self.scale
  local image = self.images[self.color]
  local scale = size / image:getWidth()
  local angle = self.static and (self.angle) or self.angle + app.grid.angle
  local ox, oy = app.grid.width / 2 * app.grid.size, app.grid.height / 2 * app.grid.size
  local cx, cy = self.x + gridSize / 2, self.y + gridSize / 2
  g.setColor(255, 255, 255)
  g.draw(image, cx, cy, angle, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

  if not self.static then
    g.setColor(255, 255, 255)
    local x2 = self.x + gridSize / 2 + math.dx(size, angle)
    local y2 = self.y + gridSize / 2 + math.dy(size, angle)
    g.setLineWidth(8)
    g.line(self.x + gridSize / 2, self.y + gridSize / 2, x2, y2)
    g.setLineWidth(1)
  end

  if not self.static then
    g.pop()
  end
end

function block:isEscaped()
  local w, h = app.grid.width * app.grid.size, app.grid.height * app.grid.size
  return self.x < 0 or self.y < 0 or self.x + app.grid.size > w or self.y + app.grid.size > h
end

function block:setPosition()
  local ox = math.floor(app.grid.width / 2) * app.grid.size
  local oy = math.floor(app.grid.height / 2) * app.grid.size

  local d = -app.grid.angle
  local c = math.cos(d)
  local s = math.sin(d)
  self.x = ((self.rx - ox) * c - (self.ry - oy) * s) + ox
  self.y = ((self.rx - ox) * s + (self.ry - oy) * c) + oy
end

function block:isOnSameSide(other)
  local left = self.x <= app.region.x1 * app.grid.size
  local right = self.x >= app.region.x2 * app.grid.size
  local otherLeft = other.x <= app.region.x1 * app.grid.size
  local otherRight = other.x >= app.region.x2 * app.grid.size

  local top = self.x <= app.region.y1 * app.grid.size
  local bottom = self.x >= app.region.y2 * app.grid.size
  local otherTop = other.x <= app.region.y1 * app.grid.size
  local otherBottom = other.x >= app.region.y2 * app.grid.size

  return left == otherLeft and top == otherTop and bottom == otherBottom and right == otherRight
end

return block
