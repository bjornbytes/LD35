local queue = {}
queue.rate = 2
queue.capacity = 3

function queue:init()
  self.items = {}
  self.timer = self.rate
  self:fill()
end

function queue:update(dt)
  self.timer = math.max(self.timer - dt, 0)

  if self.timer == 0 then
    self:generate()
    self:fill()
  end

  if self.rate > 1 then
    self.rate = self.rate - (dt / 60)
  end
end

function queue:draw()
  local size = app.grid.size
  local padding = 8

  for i = 1, #self.items do
    g.setColor(255, 255, 255)
    local image = app.block.images[self.items[i].color]
    local scale = size / image:getWidth()
    g.draw(image, 8 + (i - 1) * (size + padding), 8, 0, scale, scale)
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
  local color = _.randomchoice(app.block.colors)
  table.insert(self.items, { color = color })
end

return queue
