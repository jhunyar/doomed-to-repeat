function love.load()
  love.window.setMode(1920, 1080) -- {borderless=true}

  myWorld = love.physics.newWorld(0, 0, false)

  cursor = love.mouse.newCursor("sprites/cursor.png", 0, 0)
  love.mouse.setCursor(cursor)

  sprites = {}
  sprites.planets = {}
  
  for i = 1, 25, 1 do
    table.insert(sprites.planets, love.graphics.newImage('sprites/planets/mars' .. i .. '.png'))
  end

  sprites.player = love.graphics.newImage('sprites/ship-static.png')
  sprites.shipStatic = love.graphics.newImage('sprites/ship-static.png')
  sprites.shipLeft = love.graphics.newImage('sprites/ship-left.png')
  sprites.shipRight = love.graphics.newImage('sprites/ship-right.png')
  sprites.shipFront = love.graphics.newImage('sprites/ship-front.png')
  sprites.shipRear = love.graphics.newImage('sprites/ship-rear.png')
  sprites.bullet = love.graphics.newImage('sprites/bullet2.png')
  sprites.enemy = love.graphics.newImage('sprites/enemy.png')
  sprites.loot = love.graphics.newImage('sprites/bullet.png')
  sprites.planetAnim = love.graphics.newImage('sprites/planets/marssprites.png')
  sprites.background = love.graphics.newImage('sprites/bg.png')
  sprites.background:setWrap('repeat', 'repeat')

  panicFireRate = 0.10
  lootTimer = 10

  color = {0, 1, 1}
  fade = false

  enemies = {}
  bullets = {}
  loots = {}
  planets = {}

  gameState = 1
  maxTime = 2
  timer = maxTime
  score = 0
  showHUD = true

  fontLarge = love.graphics.newFont(40)
  fontSmall = love.graphics.newFont(20)
  fontTiny = love.graphics.newFont(10)

  require('ui')
  require('player')
  require('enemy')
  require('spawn')
  require('helpers')
  require('sound')
  require('slam')

  anim8 = require('anim8/anim8')
  sti = require('sti/sti')
  Camera = require('hump/camera')
  Timer = require('hump/timer')
  cam = Camera()

  gameMap = sti('maps/map.lua')
  mapw = gameMap.width * gameMap.tilewidth
  maph = gameMap.height * gameMap.tileheight
  cam:lookAt(mapw/2, maph/2)
  bg_quad = love.graphics.newQuad(0, 0, mapw, maph, sprites.background:getWidth(), sprites.background:getHeight())

  for i, obj in pairs(gameMap.layers['planets'].objects) do
    spawnPlanet(obj.x, obj.y, obj.width) -- x, y, size
  end
end

function love.update(dt)
  myWorld:update(dt)
  gameMap:update(dt)
  Timer.update(dt)

  updatePlayer(dt)
  updateEnemies(dt)

  -- cam:lookAt(player.body:getX(), player.body:getY())
  cam:lockPosition(player.body:getX(), player.body:getY(), cam.smooth.linear(500))

  for i,b in ipairs(bullets) do
    b.x = b.x + math.cos(b.direction) * b.speed * dt
    b.y = b.y + math.sin(b.direction) * b.speed * dt
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
    timer = timer - dt
    if timer <= 0 then
      spawnEnemy()
      maxTime = maxTime * 0.98
      timer = maxTime
    end

    lootTimer = lootTimer - dt
    if lootTimer <= 0 then
      spawnLoot()
      lootTimer = 10
    end
  end
end

function love.draw()
  cam:attach()
  
  love.graphics.setColor(1,1,1)
  if fade == true then
      love.graphics.setColor(color)
  end

  gameMap:drawLayer(gameMap.layers['Tile Layer 1'])

  love.graphics.draw(sprites.background, bg_quad, 0, 0) -- add quad variable in second position for tiling

  for i,p in ipairs(planets) do
    -- p.animation:draw(sprites.planetAnim, p.x, p.y, nil, p.size/260, p.size/260, 128, 128)

    love.graphics.draw(sprites.planets[i], p.x, p.y, nil, p.size/sprites.planets[i]:getWidth(), p.size/sprites.planets[i]:getWidth(), sprites.planets[i]:getWidth()/2, sprites.planets[i]:getHeight()/2)
  end

  for i,l in ipairs(loots) do
    love.graphics.draw(sprites.loot, l.x, l.y, nil, 0.5, 0.5, sprites.loot:getWidth()/2, sprites.loot:getHeight()/2)
  end

  drawPlayer()
  drawEnemies()

  for i,b in ipairs(bullets) do
    love.graphics.draw(sprites.bullet, b.x, b.y, b.direction, 1, 1, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
  end

  cam:detach()

  camX,camY = cam:cameraCoords(player.body:getX(), player.body:getY())

  drawHud()
end

function spawnPlanet(x, y, size)
  planet = {}

  planet.body = love.physics.newBody(myWorld, x, y, 'static')
  planet.shape = love.physics.newCircleShape(size/2)
  planet.fixture = love.physics.newFixture(planet.body, planet.shape)

  planet.x = x
  planet.y = y
  planet.size = size

  -- planet.grid = anim8.newGrid(256, 256, 2560, 2304)
  -- planet.animation = anim8.newAnimation(planet.grid('1-10',1, '1-10',2, '1-10',3, '1-10',4, '1-10',5, '1-10',6, '1-10',7, '1-10',8, '1-10',9), 0.1)

  table.insert(planets, planet)
end

function love.mousepressed(x, y, b, istouch)
  if b == 1 and gameState == 2 and player.ammo > 0 then
    spawnBullet()
  end

  if b == 2 and gameState == 2 then
    quantumLeap()
    fade = true
    Timer.tween(3, color, {1,1,1}, 'in-out-linear', function() color = {0,1,1} fade = false end)  
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
    elseif not showHUD then
      showHUD = true
    end
  end

  if key == 'w' or key == 'a' or key == 's' or key == 'd' then
    player.sprite = sprites.shipStatic
  end
end

function gravityWell(body, x, y, power, epsilon)
  local lx = x - body:getX()  -- vector x
  local ly = y - body:getY()  -- vector y
  local ldSq = lx^2 + ly^2    -- direction

  power = power * 10000 or 100000
  epsilon = epsilon * epsilon or 50 * 50

  if ldSq ~= 0 then
    local ld = math.sqrt(ldSq)
    -- removing the below code makes the gravity the same on all planets
    -- if ldSq < epsilon then
    --   ldSq = epsilon
    -- end
      
    local lfactor = (power * love.timer.getDelta()) / (ldSq * ld)
    local oldX, oldY = body:getLinearVelocity()
    body:setLinearVelocity(oldX + lx * lfactor, oldY + ly * lfactor)
  end
end