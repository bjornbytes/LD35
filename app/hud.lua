local hud = {}

function hud:init()
  self.lost = false
end

function hud:draw()
  local u, v = g.getDimensions()

  if self.lost then
    g.setColor(0, 0, 0, 192)
    local height = .55 * v
    g.rectangle('fill', 0, v * .5 - (height / 2), u, height)
  end
end

return hud
