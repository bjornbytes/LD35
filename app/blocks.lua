local blocks = {}

function blocks:init()
  blocks.list = {}
end

function blocks:add(color)
  local block = app.block(color)
  self.list[block] = block
end

function blocks:remove(block)
  if app.grid.world:hasItem(block) then
    app.grid.world:remove(block)
  end

  app.grid:removeBlock(block.gridX, block.gridY)

  block.destroying = true
  lib.flux.to(block, .3, { overlay = math.pi })
    :ease('quartout')
    :after(.2, { opacity = 0, scale = 1.75 }):ease('quintout')
    :oncomplete(function()
      self.list[block] = nil
    end)
end

function blocks:update(dt)
  _.each(self.list, 'update', dt)
end

function blocks:draw()
  _.each(self.list, 'draw')
  _.each(self.list, 'drawCursor')
  _.each(self.list, 'drawArrow')
end

function blocks:matchPattern()
  for x = 0, app.grid.width do
    for y = 0, app.grid.height do
      local group = self:getGroup(x, y)
      local hasGem = _.match(group, function(block) return block.color == 'gem' end)
      if #group >= 3 then
        score = score + ((10 * #group) * (#group - 2)) * (hasGem and 2 or 1)
        for i = 1, #group do
          local color = hasGem and 'gem' or group[i].color
          for j = 1, 10 do
            app.particles:add(group[i].x, group[i].y, color)
          end

          self:remove(group[i])
        end
        return true
      end
    end
  end
end

function blocks:getGroup(x, y)
  local block = app.grid:getBlock(x, y)

  if not block then return {} end

  local candidates = _.filter({
    left = app.grid:getBlock(x - 1, y),
    right = app.grid:getBlock(x + 1, y),
    up = app.grid:getBlock(x, y - 1),
    down = app.grid:getBlock(x, y + 1)
  }, function(x) return x end)

  local matches = {block}
  local visited = {[block] = true}

  while #candidates > 0 do
    local candidate = table.remove(candidates)
    visited[candidate] = true
    if candidate.color == block.color or candidate.color == 'gem' then
      table.insert(matches, candidate)
      local neighbors = _.filter({
        left = app.grid:getBlock(candidate.gridX - 1, candidate.gridY),
        right = app.grid:getBlock(candidate.gridX + 1, candidate.gridY),
        up = app.grid:getBlock(candidate.gridX, candidate.gridY - 1),
        down = app.grid:getBlock(candidate.gridX, candidate.gridY + 1)
      }, function(x) return x end)
      candidates = _.concat(candidates, neighbors)
      candidates = _.filter(candidates, function(c)
        return not visited[c]
      end)
    end
  end

  return matches
end

return blocks
