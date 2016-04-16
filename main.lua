local g = love.graphics

setmetatable(_G, {
  __index = require('lib/cargo').init('/')
})

require 'lib/util'

function love.load()
  print('load')
end

function love.update(dt)
  print('update')
end

function love.draw()
  g.print('draw')
end
