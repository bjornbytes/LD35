function love.conf(t)
  t.identity = 'Quadra'
  t.window.title = 'Quadra'
  t.window.icon = 'art/icon.png'
  t.window.highdpi = false
  t.window.width = 0
  t.window.height = 0
  t.window.fullscreen = true
  t.window.fullscreentype = 'exclusive'
  t.window.resizable = true
  t.modules.physics = false
end
