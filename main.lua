function love.load()
  love.window.setMode(1920, 1080, {borderless=true})

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
  -- sprites.planet = love.graphics.newImage('sprites/planets/p.png')
  sprites.planetAnim = love.graphics.newImage('sprites/planets/marssprites.png')
  sprites.background = love.graphics.newImage('sprites/bg.png')
  sprites.background:setWrap('repeat', 'repeat')

  panicFireRate = 0.10
  lootTimer = 10

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

  require('player')
  require('spawn')
  require('helpers')
  require('sound')
  require('slam')

  anim8 = require('anim8/anim8')
  sti = require('sti/sti')
  cameraFile = require('hump/camera')
  cam = cameraFile()

  gameMap = sti('maps/map.lua')
  mapw = gameMap.width * gameMap.tilewidth
  maph = gameMap.height * gameMap.tileheight
  cam:lookAt(mapw/2, maph/2)
  bg_quad = love.graphics.newQuad(0, 0, mapw, maph, sprites.background:getWidth(), sprites.background:getHeight())

  for i, obj in pairs(gameMap.layers['planets'].objects) do
    spawnPlanet(obj.x, obj.y, obj.width, obj.width*100) -- x, y, size, mass
  end
end

function love.update(dt)
  myWorld:update(dt)
  gameMap:update(dt)
  -- cam:lookAt(player.body:getX(), player.body:getY())
  cam:lockPosition(player.body:getX(), player.body:getY(), cam.smooth.linear(500))

  if gameState == 2 then
    if love.keyboard.isDown('s') and player.body:getY() < maph then -- and player.body:getY() < love.graphics.getHeight()
      player.body:applyForce(0, player.maxSpeed)
      if player_mouse_angle() > 4 and player_mouse_angle() < 5.5 then
        player.sprite = sprites.shipFront
      elseif player_mouse_angle() < 4 and player_mouse_angle() > 2.3 then
        player.sprite = sprites.shipRight
      elseif player_mouse_angle() < 2.3 and player_mouse_angle() > 0.65 then
        player.sprite = sprites.shipRear
      else
        player.sprite = sprites.shipLeft
      end
    end

    if love.keyboard.isDown('w') and player.body:getY() > 0 then -- and player.body:getY() > 0
      player.body:applyForce(0, -player.maxSpeed)
      if player_mouse_angle() > 4 and player_mouse_angle() < 5.5 then
        player.sprite = sprites.shipRear
      elseif player_mouse_angle() < 4 and player_mouse_angle() > 2.3 then
        player.sprite = sprites.shipLeft
      elseif player_mouse_angle() < 2.3 and player_mouse_angle() > 0.65 then
        player.sprite = sprites.shipFront
      else
        player.sprite = sprites.shipRight
      end
    end

    if love.keyboard.isDown('a') and player.body:getX() > 0 then -- and player.body:getX() > 0
      player.body:applyForce(-player.maxSpeed, 0)
      if player_mouse_angle() > 4 and player_mouse_angle() < 5.5 then
        player.sprite = sprites.shipRight
      elseif player_mouse_angle() < 4 and player_mouse_angle() > 2.3 then
        player.sprite = sprites.shipRear
      elseif player_mouse_angle() < 2.3 and player_mouse_angle() > 0.65 then
        player.sprite = sprites.shipLeft
      else
        player.sprite = sprites.shipFront
      end
    end

    if love.keyboard.isDown('d') and player.body:getX() < mapw then -- and player.body:getX() < love.graphics.getWidth()
      player.body:applyForce(player.maxSpeed, 0)
      if player_mouse_angle() > 4 and player_mouse_angle() < 5.5 then
        player.sprite = sprites.shipLeft
      elseif player_mouse_angle() < 4 and player_mouse_angle() > 2.3 then
        player.sprite = sprites.shipFront
      elseif player_mouse_angle() < 2.3 and player_mouse_angle() > 0.65 then
        player.sprite = sprites.shipRight
      else
        player.sprite = sprites.shipRear
      end
    end

    if player.fear > player.maxFear then
      panicFireRate = panicFireRate - dt
      if panicFireRate <= 0 and player.ammo > 0 then
        spawnBullet()

        panicFireRate = 0.10
      end
    end

    if player.fear > 0 then
      player.fear = player.fear - 2 * dt
    end

    if player.fear < 0 then
      player.fear = 0
    end
  end

  for i,p in ipairs(planets) do
    gravityWell(player.body, p.x, p.y, p.size*100, p.size*2) -- body, x, y, power, epsilon
  end

  for i,z in ipairs(enemies) do
    z.x = z.x + math.cos(enemy_player_angle(z)) * z.speed * dt
    z.y = z.y + math.sin(enemy_player_angle(z)) * z.speed * dt

    if distanceBetween(z.x, z.y, player.body:getX(), player.body:getY()) < 30 then
      enemies = {}
      loots = {}
      gameState = 1
      music:stop()
      ending:play()
      player.body:setPosition(mapw/2, maph/2)
    end

    if distanceBetween(z.x, z.y, player.body:getX(), player.body:getY()) < 100 then
      player.fear = player.fear + 3 * dt
    elseif distanceBetween(z.x, z.y, player.body:getX(), player.body:getY()) < 200 then
      player.fear = player.fear + 2 * dt
    elseif distanceBetween(z.x, z.y, player.body:getX(), player.body:getY()) < 300 then
      player.fear = player.fear + 1 * dt
    end
  end

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

  for i,z in ipairs(enemies) do
    for j,b in ipairs(bullets) do
      if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
        sndDestroy:play()
        z.dead = true
        b.dead = true
        score = score + 1
        player.ammo = player.ammo + 1
      end
    end
  end

  for i,p in ipairs(planets) do
    -- p.animation:update(dt)
  end

  for i,l in ipairs(loots) do
    if distanceBetween(l.x, l.y, player.body:getX(), player.body:getY()) < 30 then
      if l.type == 'ammo' then
        player.ammo = player.ammo + 20
      end
      
      l.claimed = true
    end
  end

  for i=#enemies, 1, -1 do
    local z = enemies[i]
    if z.dead == true then
      table.remove(enemies, i)
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

  gameMap:drawLayer(gameMap.layers['Tile Layer 1'])

  love.graphics.draw(sprites.background, bg_quad, 0, 0) -- add quad variable in second position for tiling

  for i,p in ipairs(planets) do
    -- p.animation:draw(sprites.planetAnim, p.x, p.y, nil, p.size/260, p.size/260, 128, 128)

    love.graphics.draw(sprites.planets[i], p.x, p.y, nil, p.size/sprites.planets[i]:getWidth(), p.size/sprites.planets[i]:getWidth(), sprites.planets[i]:getWidth()/2, sprites.planets[i]:getHeight()/2)
  end

  for i,l in ipairs(loots) do
    love.graphics.draw(sprites.loot, l.x, l.y, nil, 0.5, 0.5, sprites.loot:getWidth()/2, sprites.loot:getHeight()/2)
  end

  love.graphics.draw(player.sprite, player.body:getX(), player.body:getY(), player_mouse_angle(), 1, 1, sprites.player:getWidth()/2, sprites.player:getHeight()/2)

  for i,z in ipairs(enemies) do
    love.graphics.draw(sprites.enemy, z.x, z.y, enemy_player_angle(z), 1, 1, sprites.enemy:getWidth()/2, sprites.enemy:getHeight()/2)
  end

  for i,b in ipairs(bullets) do
    love.graphics.draw(sprites.bullet, b.x, b.y, b.direction, 1, 1, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
  end

  cam:detach()

  camX,camY = cam:cameraCoords(player.body:getX(), player.body:getY())

  love.graphics.setFont(fontLarge)
  if gameState == 1 then
    love.graphics.print('Click anywhere to begin!', camX + 200, camY)
  end

  if showHUD == true then
    love.graphics.setFont(fontTiny)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print('Score: ' .. score, camX - 100, camY - 80)
    love.graphics.print('Ammo: ' .. player.ammo, camX + 60, camY - 80)
    love.graphics.print('Fear: ' .. math.ceil(player.fear), camX + 60, camY + 80)
    love.graphics.print('Angle: ' .. player_mouse_angle(), camX -100, camY+80)
    love.graphics.reset()
  end
end

function spawnPlanet(x, y, size, mass)
  planet = {}

  planet.body = love.physics.newBody(myWorld, x, y, 'static')
  planet.shape = love.physics.newCircleShape(size/2)
  planet.fixture = love.physics.newFixture(planet.body, planet.shape)

  planet.x = x
  planet.y = y
  planet.size = size
  planet.mass = mass

  -- planet.grid = anim8.newGrid(256, 256, 2560, 2304)
  -- planet.animation = anim8.newAnimation(planet.grid('1-10',1, '1-10',2, '1-10',3, '1-10',4, '1-10',5, '1-10',6, '1-10',7, '1-10',8, '1-10',9), 0.1)

  table.insert(planets, planet)
end

function quantumLeap()
  local instance = sndLeap:play()
  x,y = cam:mousePosition()
  player.body:setPosition(player.body:getX() + 350 * math.cos(math.atan2(player.body:getY() - y, player.body:getX() - x) + math.pi), player.body:getY() + 350 * math.sin(math.atan2(player.body:getY() - y, player.body:getX() - x) + math.pi))
end

function love.mousepressed(x, y, b, istouch)
  if b == 1 and gameState == 2 and player.ammo > 0 then
    spawnBullet()
  end

  if b == 2 and gameState == 2 then
    quantumLeap()
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
  local lx = x - body:getX()
  local ly = y - body:getY()
  local ldSq = lx^2 + ly^2

  -- local G = (6.673*(10^-11))*3779.5275590551
  -- local F = (G*mass*body:getMass())/ldSq^2^2

  power = power * 10000 or 100000
  epsilon = epsilon * epsilon or 50 * 50

  if ldSq ~= 0 then
      local ld = math.sqrt(ldSq)
      if ldSq < epsilon then ldSq = epsilon end
      
      local lfactor = (power * love.timer.getDelta()) / (ldSq * ld)
      local oldX, oldY = body:getLinearVelocity()
      body:setLinearVelocity(oldX + lx * lfactor, oldY + ly * lfactor)
  end
end