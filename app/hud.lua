local hud = {}

function hud:init()
  self.lost = false
  self.titleFont = fonts.avenir(.066 * g.getHeight())
  self.font = fonts.avenir(.05 * g.getHeight())
end

function hud:draw()
  local u, v = g.getDimensions()

  if self.lost then
    g.setColor(0, 0, 0, 192)
    local height = .55 * v
    local top = v * .5 - (height / 2)
    g.rectangle('fill', 0, top, u, height)

    g.setColor(255, 255, 255)
    g.setFont(self.titleFont)
    local str = 'Game Over'
    g.print(str, u * .5 - g.getFont():getWidth(str) / 2, top + .08 * v)

    g.setFont(self.font)

    local str = tostring(score)
    g.print(str, u * .5 - g.getFont():getWidth(str) / 2, v * .5 - g.getFont():getHeight() / 2)

    local width = .208 * v
    local buttonHeight = .086 * v
    local bottom = top + height
    local buttonY = bottom - .08 * v - buttonHeight
    g.setColor(239, 194, 110)
    g.rectangle('fill', u * .5 - width / 2, buttonY, width, buttonHeight, 8, 8)
    g.setColor(255, 236, 200)
    g.setLineWidth(3)
    g.rectangle('line', u * .5 - width / 2, buttonY, width, buttonHeight, 8, 8)
    g.setLineWidth(1)

    local str = 'Again'
    local nudge = 4
    g.setColor(0, 0, 0, 64)
    g.print(str, u * .5 - g.getFont():getWidth(str) / 2 - nudge + 1, buttonY + buttonHeight / 2 - g.getFont():getHeight() / 2 - nudge + 1)

    g.setColor(255, 255, 255)
    g.print(str, u * .5 - g.getFont():getWidth(str) / 2 - nudge, buttonY + buttonHeight / 2 - g.getFont():getHeight() / 2 - nudge)
  end
end

function hud:mousereleased(x, y, b)
  local u, v = g.getDimensions()
  local height = .55 * v
  local top = v * .5 - (height / 2)
  local buttonWidth = .208 * v
  local buttonHeight = .086 * v
  local bottom = top + height
  local buttonY = bottom - .08 * v - buttonHeight
  if math.inside(x, y, u * .5 - buttonWidth / 2, buttonY, buttonWidth, buttonHeight) then
    love.load()
  end
end

function hud:keypressed(key)
  if key == 'space' then

  end
end

return hud
