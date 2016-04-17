local particles = {}

function particles:init()
  self.list = {}
end

function particles:add(x, y, color)
  local particle = app.particle(x, y, color)
  self.list[particle] = particle
end

function particles:remove(particle)
  self.list[particle] = nil
end

function particles:update(dt)
  _.each(self.list, 'update', dt)
end

function particles:draw()
  _.each(self.list, 'draw')
end

return particles
