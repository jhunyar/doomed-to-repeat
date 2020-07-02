function love.load()
  love.window.setMode(1920, 1080) -- {borderless=true}

  myWorld = love.physics.newWorld(0, 0, false)

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
  planets = {}

  sprites = {}
  sprites.planets = {}  
    for i = 1, 25, 1 do
      table.insert(sprites.planets, love.graphics.newImage('sprites/planets/mars' .. i .. '.png'))
    end
  sprites.player = love.graphics.newImage('sprites/ship-static.png')
  sprites.miniShip = love.graphics.newImage('sprites/miniship.png')
  sprites.shipStatic = love.graphics.newImage('sprites/ship-static.png')
  sprites.shipRotL = love.graphics.newImage('sprites/ship-rot-l.png')
  sprites.shipRotR = love.graphics.newImage('sprites/ship-rot-r.png')
  sprites.shipLeft = love.graphics.newImage('sprites/ship-left.png')
  sprites.shipLeftRotL = love.graphics.newImage('sprites/ship-left-rot-l.png')
  sprites.shipLeftRotR = love.graphics.newImage('sprites/ship-left-rot-r.png')
  sprites.shipRight = love.graphics.newImage('sprites/ship-right.png')
  sprites.shipRightRotL = love.graphics.newImage('sprites/ship-right-rot-l.png')
  sprites.shipRightRotR = love.graphics.newImage('sprites/ship-right-rot-r.png')
  sprites.shipFront = love.graphics.newImage('sprites/ship-front.png')
  sprites.shipFrontRotL = love.graphics.newImage('sprites/ship-front-rot-l.png')
  sprites.shipFrontRotR = love.graphics.newImage('sprites/ship-front-rot-r.png')
  sprites.shipRear = love.graphics.newImage('sprites/ship-rear.png')
  sprites.shipRearRotL = love.graphics.newImage('sprites/ship-rear-rot-l.png')
  sprites.shipRearRotR = love.graphics.newImage('sprites/ship-rear-rot-r.png')
  sprites.bullet = love.graphics.newImage('sprites/bullet3.png')
  sprites.enemy = love.graphics.newImage('sprites/enemy2.png')
  sprites.loot = love.graphics.newImage('sprites/bullet.png')
  sprites.planetAnim = love.graphics.newImage('sprites/planets/marssprites.png')
  sprites.planetLg = love.graphics.newImage('sprites/planets/mars-lg.png')
  sprites.background = love.graphics.newImage('sprites/bg.png')
  sprites.background:setWrap('repeat', 'repeat')

  require('ui')
  require('player')
  require('enemy')
  require('planets')
  require('spawn')
  require('helpers')
  require('sound')
  require('slam')

  lootTimer = 10

  color = {0, 1, 1}
  fade = false

  gameState = 1
  maxTime = 2
  timer = maxTime
  score = 0
  showHUD = true
  showMap = true

  fontLarge = love.graphics.newFont(40)
  fontSmall = love.graphics.newFont(20)
  fontTiny = love.graphics.newFont(10)

  gameMap = sti('maps/map-lg.lua')
  mapw = gameMap.width * gameMap.tilewidth
  maph = gameMap.height * gameMap.tileheight
  cam:lookAt(mapw/2, maph/2)
  bg_quad = love.graphics.newQuad(0, 0, mapw, maph, sprites.background:getWidth(), sprites.background:getHeight())

  for i, obj in pairs(gameMap.layers['planets'].objects) do
    spawnPlanet(obj.x, obj.y, obj.width) -- x, y, size
  end

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
  updatePlanets()

  -- cam:lookAt(player.body:getX(), player.body:getY())
  cam:lockPosition(player.body:getX(), player.body:getY(), cam.smooth.linear(500))

  for i,p in ipairs(planets) do
    if distanceBetween(p.x, p.y, player.body:getX(), player.body:getY()) < p.size/2+50 then
      p.owner = 'player'
    end
  end

  for i=#bullets, 1, -1 do
    local b = bullets[i]
    if b.x < 0 or b.y < 0 or b.x > mapw or b.y > maph then
      table.remove(bullets, i)
    end
  end

  -- for i,p in ipairs(planets) do
  --   -- p.animation:update(dt)
  -- end

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
    -- timer = timer - dt
    -- if timer <= 0 then
    --   spawnEnemy()
    --   maxTime = maxTime * 0.98
    --   timer = maxTime
    -- end

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
    -- fade = true
    -- Timer.tween(3, color, {1,1,1}, 'in-out-linear', function() color = {0,1,1} fade = false end)  
  end

  if gameState == 1 then
    gameState = 2
    maxTime = 2
    timer = maxTime
    score = 0
    player.ammo = player.maxAmmo
    player.fear = 0
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

  if key == 'w' or key == 'a' or key == 's' or key == 'd' then
    player.sprite = sprites.shipStatic
  end
end

function drawWorld()
  love.graphics.setColor(1,1,1)
  -- if fade == true then
  --     love.graphics.setColor(color)
  -- end

  gameMap:drawLayer(gameMap.layers['Tile Layer 1'])

  love.graphics.draw(sprites.background, bg_quad, 0, 0) -- add quad variable in second position for tiling

  for i,p in ipairs(planets) do
    -- p.animation:draw(sprites.planetAnim, p.x, p.y, nil, p.size/260, p.size/260, 128, 128)

    if p.size > 500 then
      love.graphics.draw(sprites.planetLg, p.x, p.y, nil, p.size/sprites.planetLg:getWidth(), p.size/sprites.planetLg:getWidth(), sprites.planetLg:getWidth()/2, sprites.planetLg:getHeight()/2)
    else
      love.graphics.draw(sprites.planets[i], p.x, p.y, nil, p.size/sprites.planets[i]:getWidth(), p.size/sprites.planets[i]:getWidth(), sprites.planets[i]:getWidth()/2, sprites.planets[i]:getHeight()/2)
    end
    if p.owner == 'player' then
      love.graphics.setColor(0,0.2,1)
      love.graphics.rectangle( 'fill', p.x-10, p.y-10, 20, 20 )
      love.graphics.setColor(1,1,1)
    elseif p.owner == 'enemy' then
      love.graphics.setColor(1,0,0)
      love.graphics.rectangle( 'fill', p.x-10, p.y-10, 20, 20 )
      love.graphics.setColor(1,1,1)
    end
  end

  for i,l in ipairs(loots) do
    love.graphics.draw(sprites.loot, l.x, l.y, nil, 0.5, 0.5, sprites.loot:getWidth()/2, sprites.loot:getHeight()/2)
  end

  drawPlayer()
  drawEnemies()

  for i,b in ipairs(bullets) do
    love.graphics.draw(sprites.bullet, b.x, b.y, b.direction, 1, 1, sprites.bullet:getWidth(), sprites.bullet:getHeight())
  end
end