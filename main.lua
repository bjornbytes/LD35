require 'lib/slam'

setmetatable(_G, {
  __index = require('lib/cargo').init('/')
})

require 'lib/util'
spine = lib.spine
_ = lib.lume
g = love.graphics

function startGame()
  score = 0
  screenshake = 0
  tick = 1

  app.grid.init()
  app.region.init()
  app.blocks:init()
  app.queue:init()
  app.particles:init()
end

function love.load()
  level = 'sky'

  score = 0
  screenshake = 0
  tick = 1

  app.grid.init()
  app.region.init()
  app.blocks:init()
  app.queue:init()
  app.particles:init()
  app.hud:init()

  app.hud.menu = true

  background = sound.background:play()
  background:setLooping(true)
  background:setVolume(.75)
end

function love.update(dt)
  tick = tick + 1
  lib.flux.update(dt)

  if not app.hud.lost and not app.hud.menu then
    app.grid:update(dt)
    app.region:update(dt)
    app.queue:update(dt)
    app.blocks:update(dt)
  end

  app.hud:update(dt)
  app.particles:update(dt)

  screenshake = math.max(screenshake - dt, 0)
end

function love.draw()
  g.setColor(50, 50, 50)
  g.rectangle('fill', 0, 0, g.getDimensions())

  local x = g.getWidth() / 2 - (app.grid.width * app.grid.size) / 2
  local y = g.getHeight() / 2 - (app.grid.height * app.grid.size) / 2

  g.push()

  g.translate(g.getWidth() / 2, g.getHeight() / 2)
  g.rotate(app.grid.angle)
  g.translate(-g.getWidth() / 2, -g.getHeight() / 2)

  local xx = x + screenshake * love.math.random() * 80 * (love.math.random() < .5 and 1 or -1)
  local yy = y + screenshake * love.math.random() * 80 * (love.math.random() < .5 and 1 or -1)
  g.translate(xx, yy)

  app.grid:draw()

  g.pop()
  g.push()
  g.translate(x, y)
  app.region:draw()

  g.pop()

  g.push()

  g.translate(g.getWidth() / 2, g.getHeight() / 2)
  g.rotate(app.grid.angle)
  g.translate(-g.getWidth() / 2, -g.getHeight() / 2)

  local xx = x + screenshake * love.math.random() * 80 * (love.math.random() < .5 and 1 or -1)
  local yy = y + screenshake * love.math.random() * 80 * (love.math.random() < .5 and 1 or -1)
  g.translate(xx, yy)

  app.blocks:drawStatic()
  app.blocks:drawDynamic()

  g.pop()
  g.push()
  g.translate(x, y)

  app.particles:draw()

  g.pop()

  app.hud:draw()
end

function love.keypressed(key)
  local blockIsMoving
  _.each(app.blocks.list, function(block)
    if not block.static and block.timer <= 0 then
      blockIsMoving = true
    end
  end)

  if key == 'left' and not blockIsMoving then
    app.grid.animating = true
    app.grid.targetAngle = (app.grid.targetAngle or app.grid.angle) - math.pi / 2
    lib.flux.to(app.grid, .35, { angle = app.grid.targetAngle })
      :ease('backout')
      :oncomplete(function()
        app.grid.animating = false
      end)
    sound.switch:play():setVolume(1.5)
  elseif key == 'right' and not blockIsMoving then
    app.grid.animating = true
    app.grid.targetAngle = (app.grid.targetAngle or app.grid.angle) + math.pi / 2
    lib.flux.to(app.grid, .35, { angle = app.grid.targetAngle })
      :ease('backout')
      :oncomplete(function()
        app.grid.animating = false
      end)
    sound.switch:play():setVolume(1.5)
  elseif key == 'space' and not app.hud.menu and not app.hud.lost then
    _.each(app.blocks.list, function(block)
      block.timer = 0
    end)
  end
end

function love.mousereleased(x, y, b)
  app.hud:mousereleased(x, y, b)
end
