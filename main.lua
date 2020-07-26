function love.load(arg)
  love.window.setMode(1920, 1080) -- {borderless=true}

  myWorld = love.physics.newWorld(0, 0, false)
  myWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)

  minimap = love.graphics.newCanvas(510, 510)

  cursor = love.mouse.newCursor("sprites/cursor.png", 0, 0)
  love.mouse.setCursor(cursor)

  moonshine = require('lib/shaders/moonshine')
  anim8 = require('lib/anim8/anim8')
  sti = require('lib/sti/sti')
  Camera = require('lib/hump/camera')
  Timer = require('lib/hump/timer')
  cam = Camera()

  enemies = {}
  bullets = {}
  loots = {}

  require('sprites')
  loadSprites()
  require('player')
  require('solarsystem')
  require('ui')
  require('enemy')
  require('spawn')
  require('helpers')
  require('sound')

  gameState = 1
  lootTimer = 10
  maxTime = 2
  timer = maxTime
  score = 0
  showHUD = true
  showMap = true
  mapZoom = 1
  showConsole = false

  fontLarge = love.graphics.newFont(40)
  fontSmall = love.graphics.newFont(20)
  fontTiny = love.graphics.newFont(10)

  gameMap = sti('maps/map-huge.lua')
  mapw = gameMap.width * gameMap.tilewidth
  maph = gameMap.height * gameMap.tileheight
  bg_quad = love.graphics.newQuad(0, 0, mapw, maph, sprites.background:getWidth(), sprites.background:getHeight())

  spawnSolarSystem(mapw/2, maph/2, 10000)

  spawnPlayer()
  cam:lookAt(player.body:getX(), player.body:getY())

  for i = 1, 100, 2 do
    spawnEnemy()
  end

  crt = moonshine(510, 510, moonshine.effects.godsray).chain(moonshine.effects.chromasep).chain(moonshine.effects.glow).chain(moonshine.effects.crt).chain(moonshine.effects.scanlines)
  crt.glow.strength = 2
  crt.chromasep.radius = 5
  crt.godsray.exposure = 0.1
  crt.godsray.density = 0.2
  crt.godsray.weight = 0.2
  crt.scanlines.width = 1
  crt.scanlines.thickness = 0.5
  crt.scanlines.opacity = 0.2
end

function love.update(dt)
  myWorld:update(dt)
  gameMap:update(dt)
  Timer.update(dt)

  updatePlayer(dt)
  updateBullets(dt)
  updateEnemies(dt)
  updatePlanets(dt)

  local cx = player.body:getX() + math.cos(player.body:getAngle()) * 200
  local cy = player.body:getY() + math.sin(player.body:getAngle()) * 200
  cam:lookAt(cx, cy)

  for i=#bullets, 1, -1 do
    local b = bullets[i]
    if b.x < 0 or b.y < 0 or b.x > mapw or b.y > maph then
      table.remove(bullets, i)
    end
  end

  for i=#bullets, 1, -1 do
    local b = bullets[i]
    if b.dead == true then
      table.remove(bullets, i)
    end
  end

  for i=#loots, 1, -1 do
    local l = loots[i]
    if l.claimed == true then
      table.remove(loots, i)
    end
  end

  if gameState == 2 then
    lootTimer = lootTimer - dt
    if lootTimer <= 0 then
      spawnLoot()
      lootTimer = 10
    end
  end
end

function love.draw()
  love.graphics.setColor(1,1,1)
  cam:attach()
  drawWorld()
  cam:detach()

  camX,camY = cam:cameraCoords(player.body:getX(), player.body:getY())

  drawHud()

  love.graphics.setCanvas(minimap)
    love.graphics.clear()
    crt(function()
      drawMinimap(mapZoom)
    end)
  love.graphics.setCanvas()
  love.graphics.setBlendMode('alpha', 'premultiplied')
  love.graphics.draw(minimap, love.graphics.getWidth() - 520, love.graphics.getHeight() - 520)
  love.graphics.setBlendMode('alpha')

  drawConsole()
end

function love.mousepressed(x, y, b, istouch)
  if b == 1 and gameState == 2 and player.ammo > 0 then
    spawnBullet()
  end

  if b == 2 and gameState == 2 then
    launch()
  end

  if gameState == 1 then
    gameState = 2
    maxTime = 2
    timer = maxTime
    score = 0
    player.ammo = player.maxAmmo
  end
end

function love.keypressed(key)
  if key == 'w' or key == 'a' or key == 's' or key == 'd' then
    if sndThrustHoldPlaying == false then
      sndThrustHoldPlaying = true
      playSound(sndThrustHold)
    end
  end
end

function love.keyreleased(key)
  if key == 'w' or key == 'a' or key == 's' or key == 'd' then
    if sndThrustHoldPlaying == true then
      sndThrustHoldPlaying = false
    end
  end

  if key == "escape" then
    love.event.quit()
  end

  if key == 'h' then
    if showHUD then
      showHUD = false
    else
      showHUD = true
    end
  end

  if key == 'm' then
    if showMap then
      showMap = false
    else
      showMap = true
    end
  end

  if key == 'c' then
    if showConsole then
      showConsole = false
    else
      showConsole = true
    end
  end

  if key == 'n' then
    if mapZoom == 0 then
      mapZoom = 1
    elseif mapZoom == 1 then
      mapZoom = 2
    elseif mapZoom == 2 then
      mapZoom = 3
    elseif mapZoom == 3 then
      mapZoom = 4
    else
      mapZoom = 0
    end
  end

  if key == 't' then
    if timeFactor == 0.00000001 then
      timeFactor = 0.000001
    else
      timeFactor = 0.00000001
    end
  end

  if key == 'q' then
    if player.linearDamping == 0 then
      player.linearDamping = 3 -- TODO is his going to cause problems later since player.linearDamping is a variable?
      player.linearDampingStatus = 'ON'
    else
      player.linearDamping = 0
      player.linearDampingStatus = 'OFF'
    end
  end

  if key == 'l' then
    lrScan()
  end

  if key == 'i' and player.scannerData[1] then
    isolateScanTarget(player.scannerData[1].x, player.scannerData[1].y, 5000)
  end

  if key == 'space' and player.warpReady == true then
    warp()
  end
end

function drawWorld()
  love.graphics.setColor(1,1,1)

  gameMap:drawLayer(gameMap.layers['Tile Layer 1'])
  love.graphics.draw(sprites.background, bg_quad, 0, 0) -- add quad variable in second position for tiling

  for i,l in ipairs(loots) do
    love.graphics.draw(sprites.loot, l.x, l.y, nil, 0.5, 0.5, sprites.loot:getWidth()/2, sprites.loot:getHeight()/2)
  end

  drawPlanets()
  drawPlayer()
  drawEnemies()
  drawBullets()
end

function beginContact(a, b, coll)
  player.landed = true
end

function endContact(a, b, coll)
  player.landed = false
end