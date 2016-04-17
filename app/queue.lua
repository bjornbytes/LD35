local queue = {}
queue.capacity = 3

function queue:init()
  self.items = {}
  self.rate = 2
  self.timer = self.rate
  self:fill()
end

function queue:update(dt)
  self.timer = math.max(self.timer - dt, 0)

  if self.timer == 0 then
    self:generate()
    self:fill()
  end

  if self.rate > 1.35 then
    self.rate = self.rate - (dt / 60)
  end
end

function queue:generate()
  local item = table.remove(self.items, 1)
  app.blocks:add(item.color)
end

function queue:fill()
  while #self.items < self.capacity do
    self:addItem()
  end
  self.timer = self.rate
end

function queue:addItem()
  local color = _.weightedchoice(app.block.colors)
  table.insert(self.items, { color = color })
end

return queue
