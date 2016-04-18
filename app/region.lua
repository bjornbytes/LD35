local region = {}

function region:init()
  region.x1 = math.floor(app.grid.width / 2) - 0
  region.y1 = math.floor(app.grid.height / 2) - 0
  region.x2 = math.floor(app.grid.width / 2) + 1
  region.y2 = math.floor(app.grid.height / 2) + 1

  region.display = {
    x1 = region.x1,
    y1 = region.y1,
    x2 = region.x2,
    y2 = region.y2
  }

  region.danger = false
end

function region:update(dt)
  if not next(_.filter(app.blocks.list, function(block)
    return block.static and app.grid.world:hasItem(block)
  end)) then
    return
  end

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
  until #(app.grid.world:queryRect(region.x1 * s, region.y1 * s, (region.x2 - region.x1) * s, (region.y2 - region.y1) * s)) > 0 or regionSize > app.grid.width

  regionSize = regionSize - 1
  setBounds(regionSize)

  region.danger = regionSize <= 2

  region.display.x1 = _.lerp(region.display.x1, region.x1, dt * 10)
  region.display.y1 = _.lerp(region.display.y1, region.y1, dt * 10)
  region.display.x2 = _.lerp(region.display.x2, region.x2, dt * 10)
  region.display.y2 = _.lerp(region.display.y2, region.y2, dt * 10)

  if regionSize == 0 then
    app.hud.lost = true
    app.hud.transform = -g.getHeight()
    app.hud.scoreDisplay = 0
    app.hud.shouldLerpScore = false
    screenshake = .35
    lib.flux.to(app.hud, .5, { transform = 0 }):ease('expoinout'):oncomplete(function()
      app.hud.shouldLerpScore = true
    end)
    if score > app.hud.highscores[level] then
      app.hud.highscores[level] = math.max(app.hud.highscores[level], score)
      app.hud.gotHighscore = true
    end
    love.filesystem.write(level .. '.txt', app.hud.highscores[level])
  end
end

function region:draw()
  g.setColor(self.danger and {255, 100, 100, 80} or {255, 255, 255, 80})
  local w = (region.display.x2 - region.display.x1) * app.grid.size
  local h = (region.display.y2 - region.display.y1) * app.grid.size
  g.rectangle('fill', region.display.x1 * app.grid.size, region.display.y1 * app.grid.size, w, h)
end

return region
