local hud = {}

function hud:init()
  self.menu = false
  self.lost = false
  self.titleFont = fonts.avenir(.066 * g.getHeight())
  self.font = fonts.avenir(.05 * g.getHeight())
  self.smallFont = fonts.avenir(.033 * g.getHeight())
  self.scoreDisplay = score

  self.transform = 0

  self.handCursor = love.mouse.getSystemCursor('hand')

  local sky = love.filesystem.read('sky.txt')
  local water = love.filesystem.read('water.txt')
  local newmexico = love.filesystem.read('newmexico.txt')
  self.highscores = {
    sky = tonumber(sky) or 0,
    water = tonumber(water) or 0,
    newmexico = tonumber(newmexico) or 0
  }
end

function hud:update(dt)
  self.scoreDisplay = _.lerp(self.scoreDisplay, score, 10 * dt)
end

function hud:draw()
  local u, v = g.getDimensions()
  local mx, my = love.mouse.getPosition()

  love.mouse.setCursor()

  if self.menu then
    g.setColor(0, 0, 0, 192)
    local height = .65 * v
    local top = v * .5 - (height / 2)
    g.rectangle('fill', 0, top, u, height)

    g.setColor(255, 255, 255)
    g.setFont(self.titleFont)
    local str = 'This Game Has a Name I Promise'
    g.setColor(0, 0, 0)
    g.print(str, u * .5 - g.getFont():getWidth(str) / 2 + 1, top + .02 * v + 1)
    g.setColor(255, 255, 255)
    g.print(str, u * .5 - g.getFont():getWidth(str) / 2, top + .02 * v)

    g.setFont(self.smallFont)

    local str = 'Use the arrow keys to rotate\nMatch blocks with the same color!'
    local bottom = top + height
    g.printf(str, 0, bottom - .02 * v - (g.getFont():getHeight() * 2), u, 'center')

    g.setColor(255, 255, 255)
    g.setFont(self.smallFont)

    local size = .2 * v
    local inc = size + .15 * v
    local xx = u * .5 - (inc * (3 - 1) / 2)

    local hover = math.inside(mx, my, xx - size / 2, v * .5 - size / 2, size, size)

    local image = art.oatline
    local scale = (size * 1.1 * (hover and 1.1 or 1)) / image:getWidth()
    g.draw(image, xx, v * .5, app.grid.angle, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

    local image = art.bg1
    local scale = (size * (hover and 1.1 or 1)) / image:getWidth()
    g.draw(image, xx, v * .5, app.grid.angle, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

    if math.inside(mx, my, xx - size / 2, v * .5 - size / 2, size, size) then
      glsl.colorize:send('color', {1, 1, 1, .25})
      g.setShader(glsl.colorize)
      g.draw(image, xx, v * .5, app.grid.angle, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
      g.setShader()
      love.mouse.setCursor(self.handCursor)
    end

    local str = 'Simple Skies'
    g.print(str, xx - g.getFont():getWidth(str) / 2, v * .5 - size / 2 - .02 * v - g.getFont():getHeight())

    local str = self.highscores.sky
    g.print(str, xx - g.getFont():getWidth(str) / 2, v * .5 + size / 2 + .02 * v)

    xx = xx + inc

    local hover = math.inside(mx, my, xx - size / 2, v * .5 - size / 2, size, size)

    local image = art.oatline
    local scale = (size * 1.1 * (hover and 1.1 or 1)) / image:getWidth()
    g.draw(image, xx, v * .5, app.grid.angle, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

    local image = art.bg2
    local scale = (size * (hover and 1.1 or 1)) / image:getWidth()
    g.draw(image, xx, v * .5, app.grid.angle, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

    if math.inside(mx, my, xx - size / 2, v * .5 - size / 2, size, size) then
      glsl.colorize:send('color', {1, 1, 1, .25})
      g.setShader(glsl.colorize)
      g.draw(image, xx, v * .5, app.grid.angle, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
      g.setShader()
      love.mouse.setCursor(self.handCursor)
    end

    local str = 'Onerous Ocean'
    g.print(str, xx - g.getFont():getWidth(str) / 2, v * .5 - size / 2 - .02 * v - g.getFont():getHeight())

    local str = self.highscores.water
    g.print(str, xx - g.getFont():getWidth(str) / 2, v * .5 + size / 2 + .02 * v)

    xx = xx + inc

    local hover = math.inside(mx, my, xx - size / 2, v * .5 - size / 2, size, size)

    local image = art.oatline
    local scale = (size * 1.1 * (hover and 1.1 or 1)) / image:getWidth()
    g.draw(image, xx, v * .5, app.grid.angle, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

    local image = art.bg3
    local scale = (size * (hover and 1.1 or 1)) / image:getWidth()
    g.draw(image, xx, v * .5, app.grid.angle, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

    if hover then
      glsl.colorize:send('color', {1, 1, 1, .25})
      g.setShader(glsl.colorize)
      g.draw(image, xx, v * .5, app.grid.angle, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
      g.setShader()
      love.mouse.setCursor(self.handCursor)
    end

    local str = 'Devastating Desert'
    g.print(str, xx - g.getFont():getWidth(str) / 2, v * .5 - size / 2 - .02 * v - g.getFont():getHeight())

    local str = self.highscores.newmexico
    g.print(str, xx - g.getFont():getWidth(str) / 2, v * .5 + size / 2 + .02 * v)

    return
  end

  g.push()
  g.translate(0, self.transform)

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

    if math.inside(mx, my, u * .5 - width / 2, buttonY, width, buttonHeight) then
      love.mouse.setCursor(self.handCursor)
    end

    local str = 'Menu'
    local nudge = 4
    g.setColor(0, 0, 0, 64)
    g.print(str, u * .5 - g.getFont():getWidth(str) / 2 - nudge + 1, buttonY + buttonHeight / 2 - g.getFont():getHeight() / 2 - nudge + 1)

    g.setColor(255, 255, 255)
    g.print(str, u * .5 - g.getFont():getWidth(str) / 2 - nudge, buttonY + buttonHeight / 2 - g.getFont():getHeight() / 2 - nudge)
  else
    g.setFont(self.font)
    g.setColor(255, 255, 255)
    local str = math.round(self.scoreDisplay)
    g.print(str, u * .5 + (app.grid.width / 2) * app.grid.size - g.getFont():getWidth(str), v * .5 - (app.grid.height / 2) * app.grid.size - g.getFont():getHeight() - 42)
  end

  g.pop()
end

function hud:mousereleased(x, y, b)
  local u, v = g.getDimensions()

  if self.lost then
    local height = .55 * v
    local top = v * .5 - (height / 2)
    local buttonWidth = .208 * v
    local buttonHeight = .086 * v
    local bottom = top + height
    local buttonY = bottom - .08 * v - buttonHeight
    if math.inside(x, y, u * .5 - buttonWidth / 2, buttonY, buttonWidth, buttonHeight) then
      self.menu = true
      self.lost = false
      sound.juju:play()
    end
  elseif self.menu then
    local height = .65 * v
    local top = v * .5 - (height / 2)

    local size = .2 * v
    local inc = size + .15 * v
    local xx = u * .5 - (inc * (3 - 1) / 2)

    local allColors = {'green', 'orange', 'red', 'purple', 'blue'}

    if math.inside(x, y, xx - size / 2, v * .5 - size / 2, size, size) then
      level = 'sky'

      local colorList = _.first(_.shuffle(allColors), 3)
      app.block.colors = {}
      app.block.colors.gem = 1
      _.each(colorList, function(c)
        app.block.colors[c] = 3
      end)

      self.menu = false
      startGame()

      sound.juju:play()

      return
    end

    xx = xx + inc

    if math.inside(x, y, xx - size / 2, v * .5 - size / 2, size, size) then
      level = 'water'

      local colorList = _.first(_.shuffle(allColors), 4)
      app.block.colors = {}
      app.block.colors.gem = 1
      _.each(colorList, function(c)
        app.block.colors[c] = 3
      end)

      self.menu = false
      startGame()

      sound.juju:play()

      return
    end

    xx = xx + inc

    if math.inside(x, y, xx - size / 2, v * .5 - size / 2, size, size) then
      level = 'newmexico'

      local colorList = _.first(_.shuffle(allColors), 5)
      app.block.colors = {}
      app.block.colors.gem = 1
      _.each(colorList, function(c)
        app.block.colors[c] = 3
      end)

      self.menu = false
      startGame()

      sound.juju:play()

      return
    end
  end
end

function hud:keypressed(key)
  if key == 'space' then
    --
  end
end

return hud
