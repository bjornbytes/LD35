local particle = class()

function particle:init(x, y, color)
  local ox = math.floor(app.grid.width / 2) * app.grid.size
  local oy = math.floor(app.grid.height / 2) * app.grid.size

  local d = app.grid.angle
  local c = math.cos(d)
  local s = math.sin(d)
  self.x = ((x - ox) * c - (y - oy) * s) + ox
  self.y = ((x - ox) * s + (y - oy) * c) + oy

  self.x = self.x + love.math.randomNormal(10)
  self.y = self.y + love.math.randomNormal(10)

  self.x = self.x + app.grid.size / 2
  self.y = self.y + app.grid.size / 2

  self.angle = love.math.random() * 2 * math.pi
  self.scale = love.math.random(10, 20)
  self.opacity = 1
  if color == 'gem' then
    self.color = { love.math.random(150, 255), love.math.random(150, 255), love.math.random(150, 255) }
  else
    self.color = app.block.hues[color]
  end

  self.speed = {
    x = love.math.random(-200, 200),
    y = love.math.random(-800, -200)
  }

  self.gravity = 2000
end

function particle:update(dt)
  self.x = self.x + self.speed.x * dt
  self.y = self.y + self.speed.y * dt
  self.speed.y = self.speed.y + self.gravity * dt

  self.opacity = self.opacity - (dt * 2)
  if self.opacity <= 0 then
    app.particles:remove(self)
  end
end

function particle:draw()
  local color = self.color
  local image = art.star2
  local scale = (self.scale * 2) / image:getWidth()
  g.setColor(color[1], color[2], color[3], self.opacity * 255)
  g.draw(image, self.x, self.y, self.angle, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
  g.setBlendMode('add')
  g.setColor(color[1], color[2], color[3], self.opacity * 150)
  g.draw(image, self.x, self.y, self.angle, scale * 1.25, scale * 1.25, image:getWidth() / 2, image:getHeight() / 2)
  g.setBlendMode('alpha')
end

return particle
