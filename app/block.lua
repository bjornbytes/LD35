local block = class()

block.colors = {
  red = {255, 50, 50},
  blue = {50, 50, 255}
}

block.speed = 500

function block:init()
  self.rx = love.math.random(app.region.x1, app.region.x2 - 1) * app.grid.size
  self.ry = love.math.random(app.region.y1, app.region.y2 - 1) * app.grid.size

  self.angle = math.floor(love.math.random() * 2 * math.pi / (math.pi / 2)) * (math.pi / 2)
  self.timer = 2
  self.color = _.randomchoice(_.keys(block.colors))

  self.scale = 0
  lib.flux.to(self, .3, { scale = 1 }):ease('backout')

  self.static = false
end

function block:update(dt)
  if self.static then return end

  self.timer = math.max(self.timer - dt, 0)

  if self.timer <= 0 and math.abs(math.anglediff(app.grid.angle, app.grid.targetAngle)) < .01 then
    self.x = self.x + math.dx(self.speed * dt, self.angle - app.grid.angle)
    self.y = self.y + math.dy(self.speed * dt, self.angle - app.grid.angle)

    local hasCollision = false

    if #app.grid.world:queryRect(self.x, self.y, app.grid.size, app.grid.size) > 0 then
      hasCollision = true
    end

    if self:isEscaped() or hasCollision then
      self.x = math.round(self.x / app.grid.size) * app.grid.size
      self.y = math.round(self.y / app.grid.size) * app.grid.size

      self.static = true
      app.grid.world:add(self, self.x + 4, self.y + 4, app.grid.size - 8, app.grid.size - 8)
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

  g.setColor(self.colors[self.color])
  local size = app.grid.size * self.scale
  g.rectangle('fill', self.x + gridSize / 2 - size / 2, self.y + gridSize / 2 - size / 2, size, size)

  if not self.static then
    g.setColor(255, 255, 255)
    local x2 = self.x + gridSize / 2 + math.dx(size / 2, self.angle)
    local y2 = self.y + gridSize / 2 + math.dy(size / 2, self.angle)
    g.line(self.x + gridSize / 2, self.y + gridSize / 2, x2, y2)
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

return block
