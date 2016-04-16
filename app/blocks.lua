local blocks = {}

blocks.list = {}

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
  do
    return
  end

  print('---')
  for x = 0, app.grid.width do
    io.write('|')
    for y = 0, app.grid.height do
      local block = app.grid:getBlock(x, y)
      if block then
        io.write(block.color == 'purple' and 'P' or 'O')
      else
        io.write(' ')
      end
    end
    io.write('|\n')
  end
  print('---')

  for x = 0, app.grid.width do
    for y = 0, app.grid.height do
      local block = app.grid:getBlock(x, y)

      if block then
        do
          local candidates = {}

          local xx = x + 1
          while xx <= app.grid.width do
            local other = app.grid:getBlock(xx, y)
            if not other or other.color ~= block.color then
              if #candidates >= 3 then
                print('pattern')
                for i = 1, #candidates do
                  self:remove(candidates[i])
                end
              end
              break
            else
              table.insert(candidates, other)
            end
            xx = xx + 1
          end
        end

        do
          local candidates = {}

          local yy = y + 1
          while yy <= app.grid.height do
            local other = app.grid:getBlock(x, yy)
            if not other or other.color ~= block.color then
              if #candidates >= 3 then
                print('pattern')
                for i = 1, #candidates do
                  self:remove(candidates[i])
                end
              end
              break
            else
              table.insert(candidates, other)
            end
            yy = yy + 1
          end
        end
      end
    end
  end
end

return blocks
