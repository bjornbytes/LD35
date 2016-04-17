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
  self.list[block] = nil
end

function blocks:update(dt)
  _.each(self.list, 'update', dt)
end

function blocks:drawStatic()
  _.each(_.filter(self.list, 'static'), 'draw')
end

function blocks:drawDynamic()
  _.each(_.reject(self.list, 'static'), 'draw')
end

function blocks:matchPattern()
  for x = 0, app.grid.width do
    for y = 0, app.grid.height do
      local group = self:getGroup(x, y)
      if #group >= 3 then
        for i = 1, #group do
          self:remove(group[i])
        end
      end
    end
  end
end

function blocks:getGroup(x, y)
  local block = app.grid:getBlock(x, y)

  if not block then return {} end

  if block.color == 'gem' then
    local groups = {}

    local left = app.grid:getBlock(x - 1, y)
    if left and left.color ~= 'gem' then
      groups = _.concat(groups, self:getGroup(x - 1, y))
    end

    local right = app.grid:getBlock(x + 1, y)
    if right and right.color ~= 'gem' then
      groups = _.concat(groups, self:getGroup(x + 1, y))
    end

    local top = app.grid:getBlock(x, y - 1)
    if top and top.color ~= 'gem' then
      groups = _.concat(groups, self:getGroup(x, y - 1))
    end

    local bottom = app.grid:getBlock(x, y + 1)
    if bottom and bottom.color ~= 'gem' then
      groups = _.concat(groups, self:getGroup(x, y + 1))
    end

    return _.concat(groups, {block})
  end

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
    if candidate.color == block.color then
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
