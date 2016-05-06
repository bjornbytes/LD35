local grid = {}

grid.size = 100
grid.width = 9
grid.height = 9
grid.backgrounds = {
  sky = art.bg1,
  water = art.bg2,
  newmexico = art.bg3
}

function grid.init()
  grid.world = lib.bump.newWorld(grid.size)
  grid.angle = 0
  grid.targetAngle = 0
  grid.blocks = {}
end

function grid:update(dt)
  --grid.angle = math.anglerp(grid.angle, grid.targetAngle, math.min(10 * dt, 1))
end

function grid:draw()
  local image = art.oatline
  local scale = ((grid.width * grid.size) + 80) / image:getWidth()
  --g.draw(image, grid.width * grid.size / 2, grid.height * grid.size / 2, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
  g.setColor(68, 68, 68)
  g.rectangle('fill', -40, -40, app.grid.width * app.grid.size + 80, app.grid.width * app.grid.size + 80, 32, 32)

  g.setColor(255, 255, 255)
  local image = self.backgrounds[level]
  local scale = (grid.width * grid.size) / image:getWidth()
  g.draw(image, 0, 0, 0, scale, scale)
end

function grid:cell(x, y)
  return math.floor(x / grid.size), math.floor(y / grid.size)
end

function grid:pos(x, y)
  return math.floor(x) * grid.size, math.floor(y) * grid.size
end

function grid:setBlock(x, y, block)
  local node = tostring(x) .. ':' .. tostring(y)
  self.blocks[node] = block
end

function grid:getBlock(x, y)
  local node = tostring(x) .. ':' .. tostring(y)
  return self.blocks[node]
end

function grid:removeBlock(x, y)
  local node = tostring(x) .. ':' .. tostring(y)
  self.blocks[node] = nil
end

return grid
