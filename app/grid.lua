local grid = {}

grid.size = 30
grid.width = 11
grid.height = 11

function grid.init()
  grid.world = lib.bump.newWorld(grid.size)
  grid.angle = 0
  grid.targetAngle = grid.angle
end

function grid:update(dt)
  grid.angle = math.anglerp(grid.angle, grid.targetAngle, math.min(10 * dt, 1))
end

function grid:draw()
  g.setColor(255, 255, 255)

  if love.keyboard.isDown('`') then
    for x = 0, grid.width do
      g.line(x * grid.size, 0, x * grid.size, grid.height * grid.size)
    end

    for y = 0, grid.height do
      g.line(0, y * grid.size, grid.width * grid.size, y * grid.size)
    end
  end

  g.setLineWidth(2)
  g.setColor(255, 255, 255, 80)
  g.rectangle('line', 0, 0, self.width * self.size, self.height * self.size)

  g.setLineWidth(1)
end

function grid:cell(x, y)
  return math.floor(x / grid.size), math.floor(y / grid.size)
end

function grid:pos(x, y)
  return math.floor(x) * grid.size, math.floor(y) * grid.size
end

return grid
