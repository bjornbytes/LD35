local block = class()

block.colors = { orange = 3, purple = 3, green = 3, red = 3, blue = 3, gem = 1 }
block.images = {
  red = art.redblock,
  orange = art.orangeblock,
  purple = art.purpleblock,
  green = art.greenblock,
  gem = art.gem
}
block.hues = {
  orange = { 213, 153, 122 },
  purple = { 169, 139, 196 },
  green = { 135, 175, 121 },
  red = { 163, 87, 87 },
  blue = { 91, 123, 159 },
  gem = { 235, 85, 177 }
}

block.animationConfig = {
  dir = 'art/animation',
  scale = app.grid.size / art.redblock:getWidth(),
  states = {
    eyesLeft = {
      loop = false,
      track = 1
    },
    eyesRight = {
      loop = false,
      track = 1
    },

    gem = {
      loop = true
    },

    ['green-idle'] = {
      loop = true
    },
    ['red-idle'] = {
      loop = true
    },
    ['purple-idle'] = {
      loop = true
    },
    ['orange-idle'] = {
      loop = true
    },
    ['blue-idle'] = {
      loop = true
    },

    ['green-launch'] = {
      loop = false,
      speed = 1
    },
    ['red-launch'] = {
      loop = false,
      speed = 1
    },
    ['purple-launch'] = {
      loop = false,
      speed = 1
    },
    ['orange-launch'] = {
      loop = false,
      speed = 1
    },
    ['blue-launch'] = {
      loop = false,
      speed = 1
    },

    ['green-land'] = {
      loop = false,
      speed = 1
    },
    ['red-land'] = {
      loop = false,
      speed = 1
    },
    ['purple-land'] = {
      loop = false,
      speed = 1
    },
    ['orange-land'] = {
      loop = false,
      speed = 1
    },
    ['blue-land'] = {
      loop = false,
      speed = 1
    }
  }
}

block.speed = 4000
block.delays = {
  sky = 1.25,
  water = 1.125,
  newmexico = 1
}

function block:init(color)
  self.rx = love.math.random(app.region.x1, app.region.x2 - 1) * app.grid.size
  self.ry = love.math.random(app.region.y1, app.region.y2 - 1) * app.grid.size

  local config = table.copy(self.animationConfig)
  config.on = {
    complete = function(animation, state)
      if self.color ~= 'gem' and state.name:match('%-land$') then
        animation:set(color .. '-idle')
      end
    end
  }

  if color == 'gem' then
    config.scale = app.grid.size / art.gem:getWidth()
  end

  self.animation = lib.chiro.create(config)

  if color == 'gem' then
    self.animation:set('gem')
  else
    self.animation:set(color .. '-launch')
  end

  self.angle = math.floor(love.math.random() * 2 * math.pi / (math.pi / 2)) * (math.pi / 2)
  self.timer = self.delays[level]
  self.color = color
  self.originalAngle = self.angle
  self.arrowFactor = 0
  self.overlay = 0
  self.opacity = 1

  self.fiddleTimer = 0

  self.scale = 0
  lib.flux.to(self, .3, { scale = 1, arrowFactor = 1 }):ease('backout')

  local sound = _.randomchoice({sound.pop1, sound.pop2, sound.pop3, sound.pop4, sound.pop5})
  sound:play()
  sound:setVolume(.5)

  self.static = false
end

function block:update(dt)
  self.animation:update(dt)

  if self.fiddleTimer > 0 then
    self.fiddleTimer = math.max(self.fiddleTimer - dt, 0)
    if self.fiddleTimer <= 0 then
      if self.color ~= 'gem' then
        self.animation:set(love.math.random() > .5 and 'eyesLeft' or 'eyesRight')
      end
      self.fiddleTimer = love.math.random(5, 10)
    end
  end

  if self.static then return end

  self.angle = self.originalAngle - app.grid.angle

  if not app.grid.animating and self.timer > 0 then
    self.timer = math.max(self.timer - dt, 0)
    if self.timer == 0 then
      self.angle = math.round(self.angle / (math.pi / 2)) * (math.pi / 2)
      self:setPosition()
    end
  end

  if self.timer <= 0 and not app.grid.animating then
    self.angle = math.round(self.angle / (math.pi / 2)) * (math.pi / 2)

    local ox, oy = self.x, self.y
    local s = app.grid.size
    local len = self.speed * dt
    self.x = ox + math.dx(self.speed * dt, self.angle)
    self.y = oy + math.dy(self.speed * dt, self.angle)

    while
      (#app.grid.world:querySegment(ox + s / 2, oy + s / 2, self.x + s / 2, self.y + s / 2) > 0 or
        self.x < -1 or self.y < -1 or self.x + s > app.grid.width * s + 1 or self.y + s > app.grid.height * s + 1)
        and len > dt do
          len = len / 2
          self.x = ox + math.dx(len, self.angle)
          self.y = oy + math.dy(len, self.angle)
    end

    local hasCollision = false

    if #app.grid.world:queryRect(self.x + 8, self.y + 8, app.grid.size - 16, app.grid.size - 16) > 0 then
      hasCollision = true
    end

    if self:isEscaped() or hasCollision then
      self.x = math.round(self.x / app.grid.size) * app.grid.size
      self.y = math.round(self.y / app.grid.size) * app.grid.size

      self.static = true
      app.grid.world:add(self, self.x + 8, self.y + 8, app.grid.size - 16, app.grid.size - 16)
      self.gridX = math.round(self.x / app.grid.size)
      self.gridY = math.round(self.y / app.grid.size)

      if app.grid:getBlock(self.gridX, self.gridY) then
        app.blocks:remove(app.grid:getBlock(self.gridX, self.gridY))
      end

      app.grid:setBlock(self.gridX, self.gridY, self)
      self.angle = self.originalAngle - app.grid.angle
      self.angle = math.round(self.angle / (math.pi / 2)) * (math.pi / 2)
      self.arrowFactor = 1.2
      lib.flux.to(self, .3, { arrowFactor = 0 }):ease('backin')

      if app.blocks:matchPattern() then
        if not muted then
          sound.amulet:play()
        end
        screenshake = .25
      else
        if not muted then
          sound.juju:play()
        end
        screenshake = .15
      end

      self.fiddleTimer = love.math.random(1, 10)

      if self.color ~= 'gem' then
        self.animation:set(self.color .. '-land')
      end

      score = score + 1
    end
  else
    self:setPosition()
  end
end

function block:drawArrow()
  local gridSize = app.grid.size
  local size = gridSize * self.scale

  if not self.static then
    g.push()
    g.translate((self.x + gridSize / 2), (self.y + gridSize / 2))
    g.rotate(-app.grid.angle)
    g.translate(-(self.x + gridSize / 2), -(self.y + gridSize / 2))
  end

  if self.arrowFactor > 0 then
    local angle = self.static and self.originalAngle - app.grid.angle or self.angle + app.grid.angle
    local x = self.x + gridSize / 2 + math.dx(size, angle)
    local y = self.y + gridSize / 2 + math.dy(size, angle)
    local image = art.arrow
    local scale = (60 / image:getWidth()) * self.arrowFactor
    scale = scale * (1 + math.sin(tick / 10) / 10)
    g.setColor(255, 255, 200, 255 * _.clamp(self.arrowFactor, 0, 1))
    g.draw(image, x, y, angle, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
  end

  if not self.static then
    g.pop()
  end
end

function block:drawCursor()
  local gridSize = app.grid.size

  local size = gridSize * self.scale
  local image = self.images[self.color]
  local ox, oy = app.grid.width / 2 * gridSize, app.grid.height / 2 * gridSize
  local cx, cy = self.x + gridSize / 2, self.y + gridSize / 2

  if not self.static then
    g.push()
    g.translate((self.x + gridSize / 2), (self.y + gridSize / 2))
    g.rotate(-app.grid.angle)
    g.translate(-(self.x + gridSize / 2), -(self.y + gridSize / 2))
  end

  if self.timer > 0 then
    local factor = self.timer / self.delays[level]
    local size = _.lerp(app.grid.size, app.grid.size * 2, factor)
    local alpha = 255 * (1 - factor)
    local color = app.block.hues[app.queue.items[1].color]
    g.setLineWidth(8)
    g.setColor(color[1], color[2], color[3], alpha)
    g.rectangle('line', cx - size / 2, cy - size / 2, size, size, 8, 8)
    g.setLineWidth(1)
  end

  if not self.static then
    g.pop()
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
  local ox, oy = app.grid.width / 2 * app.grid.size, app.grid.height / 2 * app.grid.size
  local cx, cy = self.x + gridSize / 2, self.y + gridSize / 2

  self.animation.skeleton.a = self.opacity

  local angle = self.static and -self.angle or -self.angle - app.grid.angle
  self.animation.skeleton:findBone('root').scaleX = self.scale
  self.animation.skeleton:findBone('root').scaleY = self.scale
  self.animation.skeleton:findBone('root').rotation = math.deg(angle + math.pi / 2)
  self.animation:draw(cx, cy)
  if self.overlay > 0 then
    glsl.colorize:send('color', { 1, 1, 1, math.sin(self.overlay) })
    g.setShader(glsl.colorize)
    self.animation:draw(cx, cy)
    g.setShader()
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
