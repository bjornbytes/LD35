local region = {}

function region:init()
  region.x1 = math.floor(app.grid.width / 2) - 0
  region.y1 = math.floor(app.grid.height / 2) - 0
  region.x2 = math.floor(app.grid.width / 2) + 1
  region.y2 = math.floor(app.grid.height / 2) + 1
end

function region:update()
  if not next(_.filter(app.blocks.list, 'static')) then return end

  local function setBounds(regionSize)
    region.x1 = math.floor(app.grid.width / 2) - (regionSize - 1)
    region.y1 = math.floor(app.grid.height / 2) - (regionSize - 1)
    region.x2 = math.floor(app.grid.width / 2) + regionSize
    region.y2 = math.floor(app.grid.height / 2) + regionSize
  end

  local s = app.grid.size
  local regionSize = 0

  repeat
    regionSize = regionSize + 1
    setBounds(regionSize)
  until #(app.grid.world:queryRect(region.x1 * s, region.y1 * s, (region.x2 - region.x1) * s, (region.y2 - region.y1) * s)) > 0
    or regionSize > app.grid.width

  regionSize = regionSize - 1
  setBounds(regionSize)

  if regionSize == 0 then
    print('you lose')
    love.event.quit()
  end
end

function region:draw()
  g.setColor(255, 255, 255, 80)
  local w = (region.x2 - region.x1) * app.grid.size
  local h = (region.y2 - region.y1) * app.grid.size
  g.rectangle('line', region.x1 * app.grid.size, region.y1 * app.grid.size, w, h)
end

return region
