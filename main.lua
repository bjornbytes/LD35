setmetatable(_G, {
  __index = require('lib/cargo').init('/')
})

require 'lib/util'
_ = lib.lume
g = love.graphics

function love.load()
  print('load')
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
end

function love.draw()
  local x = g.getWidth() / 2 - (app.grid.width * app.grid.size) / 2
  local y = g.getHeight() / 2 - (app.grid.height * app.grid.size) / 2

  g.push()

  g.translate(g.getWidth() / 2, g.getHeight() / 2)
  g.rotate(app.grid.angle)
  g.translate(-g.getWidth() / 2, -g.getHeight() / 2)

  g.translate(x, y)

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
    app.grid.targetAngle = app.grid.targetAngle - math.pi / 2
  elseif key == 'right' then
    app.grid.targetAngle = app.grid.targetAngle + math.pi / 2
  end
end
