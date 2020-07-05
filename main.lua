function love.load(arg)
  love.window.setMode(1920, 1080) -- {borderless=true}

  myWorld = love.physics.newWorld(0, 0, false)
  myWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)

  cursor = love.mouse.newCursor("sprites/cursor.png", 0, 0)
  love.mouse.setCursor(cursor)

  anim8 = require('anim8/anim8')
  sti = require('sti/sti')
  Camera = require('hump/camera')
  Timer = require('hump/timer')
  cam = Camera()

  enemies = {}
  bullets = {}
  loots = {}

  require('sprites')
  setSprites()
  require('player')
  require('solarsystem')
  require('ui')
  require('enemy')
  -- require('planets')
  require('spawn')
  require('helpers')
  require('sound')
  require('slam')

  gameState = 1
  lootTimer = 10
  maxTime = 2
  timer = maxTime
  score = 0
  showHUD = true
  showMap = true

  fontLarge = love.graphics.newFont(40)
  fontSmall = love.graphics.newFont(20)
  fontTiny = love.graphics.newFont(10)

  gameMap = sti('maps/map-huge.lua')
  mapw = gameMap.width * gameMap.tilewidth
  maph = gameMap.height * gameMap.tileheight
  cam:lookAt(mapw/2, maph/2)
  bg_quad = love.graphics.newQuad(0, 0, mapw, maph, sprites.background:getWidth(), sprites.background:getHeight())

  spawnSolarSystem(mapw/2, maph/2, 10000)
  -- for i, obj in pairs(gameMap.layers['planets'].objects) do
  --   spawnPlanet(obj.x, obj.y, obj.width) -- x, y, size
  -- end
-- spawn player at
  local angle = math.rad(love.math.random(0, 360))
  local playerX = star.body:getX() + star.size * math.cos(angle)
  local playerY = star.body:getY() + star.size * math.sin(angle)
  spawnPlayer(playerX, playerY)

  for i = 1, 100, 2 do
    spawnEnemy()
  end

  ending:stop()
  music:play()
end

function love.update(dt)
  myWorld:update(dt)
  gameMap:update(dt)
  Timer.update(dt)

  updatePlayer(dt)
  updateBullets(dt)
  updateEnemies(dt)
  updatePlanets(dt)

  cam:lookAt(player.body:getX(), player.body:getY())
  -- cam:lockPosition(player.body:getX(), player.body:getY(), cam.smooth.linear(500))

  for i,o in ipairs(star.orbits) do
    if o.planet then
      if distanceBetween(o.planet.body:getX(), o.planet.body:getY(), player.body:getX(), player.body:getY()) < o.planet.size/2+50 then
        o.planet.owner = 'player'
      end
    end
  end

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
  drawMinimap()
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

function love.keyreleased(key)
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

  if key == 'w' or key == 'a' or key == 's' or key == 'd' then
    player.sprite = sprites.shipStatic
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