local blocks = {}

blocks.list = {}

function blocks:add()
  local block = app.block()
  self.list[block] = block
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

return blocks
