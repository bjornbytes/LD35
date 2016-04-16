setmetatable(_G, {
  __index = require('lib/cargo').init('/')
})

require 'lib/util'
_ = lib.lume
g = love.graphics

screenshake = 0

function love.load()
  app.grid.init()
  app.region.init()
  app.queue:init()
end

function love.update(dt)
  lib.flux.update(dt)
  app.grid:update(dt)
  app.region:update(dt)
  app.queue:update(dt)
  app.blocks:update(dt)

  screenshake = math.max(screenshake - dt, 0)
end

function love.draw()
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
  app.blocks:drawStatic()
  app.blocks:drawDynamic()

  g.pop()
  g.push()

  g.translate(x, y)

  app.region:draw()

  g.pop()

  app.queue:draw()
end

function love.keypressed(key)
  if key == 'left' then
    app.grid.animating = true
    app.grid.targetAngle = (app.grid.targetAngle or app.grid.angle) - math.pi / 2
    lib.flux.to(app.grid, .25, { angle = app.grid.targetAngle })
      :ease('backout')
      :oncomplete(function()
        app.grid.animating = false
      end)
  elseif key == 'right' then
    app.grid.animating = true
    app.grid.targetAngle = (app.grid.targetAngle or app.grid.angle) + math.pi / 2
    lib.flux.to(app.grid, .25, { angle = app.grid.targetAngle })
      :ease('backout')
      :oncomplete(function()
        app.grid.animating = false
      end)
  end
end
