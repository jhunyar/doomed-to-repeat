require('solarsystem')
sti = require('sti/sti')
gameMap = sti('maps/map-huge.lua')

mapw = gameMap.width * gameMap.tilewidth
maph = gameMap.height * gameMap.tileheight

function spawnPlayer(x, y)
  player = {}
  player.body = love.physics.newBody(myWorld, x, y, 'dynamic')
  player.shape = love.physics.newRectangleShape(100, 100)
  player.fixture = love.physics.newFixture(player.body, player.shape)
  
  player.forces = {0,0,0,0} -- thruster booleans
  player.landed = false
  player.linearDampingStatus = 'OFF'
  player.linearDamping = 0
  player.thrust = 100
  player.maxSpeed = 600
  player.acceleration = 50000
  player.rotSpeed = 10000
  player.currentSector = math.ceil(player.body:getX()/2000 - 250) .. ':' .. math.ceil(player.body:getY()/2000 - 250)
  
  player.maxAmmo = 100
  player.ammo = 100
  player.sprite = sprites.shipStatic
  
  player.scannerData = {}
  player.warpTargetX = 0
  player.warpTargetY = 0
  player.warpReady = false
  
  player.body:setMass(500)
  player.body:setLinearDamping(player.linearDamping)
  -- player.body:setFixedRotation(true)
end

function updatePlayer(dt)
  if gameState == 2 then
    player.currentSector = math.ceil(player.body:getX()/2000 - 250) .. ':' .. math.ceil(player.body:getY()/2000 - 250)
    if player.body:getY() > maph or player.body:getY() < 0 or player.body:getX() < 0 or player.body:getX() > mapw then
      player.body:setLinearDamping(1.5)
    else
      player.body:setLinearDamping(player.linearDamping)
    end

    local f = table.concat(player.forces)
    if f == '0000' then player.sprite = sprites.shipStatic end
    if f == '1000' then player.sprite = sprites.shipRear end
    if f == '1100' then player.sprite = sprites.shipRearRotL end
    if f == '1001' then player.sprite = sprites.shipRearRotR end
    if f == '0010' then player.sprite = sprites.shipFront end
    if f == '0110' then player.sprite = sprites.shipFrontRotL end
    if f == '0011' then player.sprite = sprites.shipFrontRotR end
    if f == '0100' then player.sprite = sprites.shipRotL end
    if f == '0001' then player.sprite = sprites.shipRotR end

    local angle = player.body:getAngle()
    local x = math.cos(angle) * player.acceleration
    local y = math.sin(angle) * player.acceleration
    
    -- originally when 's' was down, applyForce 0, player.thrust*1000. 's' should only handle applying force opposite the player's angle now!
    if love.keyboard.isDown('w') and player.body:getY() < maph then -- and player.body:getY() < love.graphics.getHeight()
      player.body:applyForce(x, y)
    end

    if love.keyboard.isDown('a') and player.body:getY() > 0 then -- and player.body:getY() > 0
      player.body:applyTorque(-player.rotSpeed)
    end

    if love.keyboard.isDown('s') and player.body:getX() > 0 then -- and player.body:getX() > 0
      player.body:applyForce(-x, -y)
    end

    if love.keyboard.isDown('d') and player.body:getX() < mapw then -- and player.body:getX() < love.graphics.getWidth()
      player.body:applyTorque(player.rotSpeed)
    end

    -- local vx, vy = player.body:getLinearVelocity()
    -- -- vx, vy = clamp(vx, vy, player.maxSpeed)
    -- player.body:setLinearVelocity(vx, vy)

    for i,l in ipairs(loots) do
      if distanceBetween(l.x, l.y, player.body:getX(), player.body:getY()) < 30 then
        if l.type == 'ammo' then
          player.ammo = player.ammo + 20
        end
        
        l.claimed = true
      end
    end

    for i,o in ipairs(star.orbits) do
      if o.planet then
        gravityWell(player.body, o.planet.body:getX(), o.planet.body:getY(), o.planet.size*10, o.planet.size*4) -- body, x, y, power, epsilon
      end
    end
  end
end

-- function drawThrusters()

-- end

function drawPlayer()
  if distanceBetween(player.body:getX(), player.body:getY(), star.body:getX(), star.body:getY()) < star.size then
    love.graphics.setColor(1, 1, 0)
  end
  love.graphics.draw(player.sprite, player.body:getX(), player.body:getY(), player.body:getAngle(), 1, 1, sprites.player:getWidth()/2, sprites.player:getHeight()/2)
  love.graphics.setColor(1, 1, 1)
end

function launch()
  -- playSound(sndLaunch)
  player.landed = false
  if player.joint then
    if not player.joint:isDestroyed() then
      player.joint:destroy()
    end
  end
  if player.moonJoint then
    if not player.moonJoint:isDestroyed() then
      player.moonJoint:destroy()
    end
  end
  mx,my = cam:mousePosition()
  bx,by = player.body:getPosition()
  dx, dy = mx - bx, my - by
  d = math.sqrt ( dx * dx + dy * dy )
  ndx, ndy = dx / d, dy / d
  impulse = 500000
  ix, iy = ndx * impulse, ndy * impulse
  player.linearDamping = 0
  player.linearDampingStatus = 'OFF'

  player.body:applyLinearImpulse(ix, iy, player.body:getX(), player.body:getY())
end

function spawnBullet()
  playSound(sndShoot)

  bullet = {}

  local vx, vy = player.body:getLinearVelocity()
  if vx < 0 then vx = vx * -1 end
  if vy < 0 then vy = vy * -1 end

  bullet.x = player.body:getX()
  bullet.y = player.body:getY()
  bullet.speed = 1000 + math.floor(vx+vy)
  bullet.direction = player.body:getAngle()
  bullet.dead = false

  table.insert(bullets, bullet)

  player.ammo = player.ammo - 1
end

function drawBullets()
  for i,b in ipairs(bullets) do
    love.graphics.draw(sprites.bullet, b.x, b.y, b.direction, 1, 1, sprites.bullet:getWidth(), sprites.bullet:getHeight())
  end
end

function updateBullets(dt)
  for i,b in ipairs(bullets) do
    b.x = b.x + math.cos(b.direction) * b.speed * dt
    b.y = b.y + math.sin(b.direction) * b.speed * dt
  end
end

function lrScan()
  player.scannerData = {}
  local angle = player.body:getAngle()

  for i,o in ipairs(star.orbits) do
    -- local r = math.sqrt((p.body:getX() - player.body:getX())^2 + (p.body:getY() - player.body:getY())^2)
    if o.planet then
      local r = 500000
      local a = math.atan2(player.body:getY() - o.planet.body:getY(), player.body:getX() - o.planet.body:getX()) + math.pi
      local s = angle - math.rad(5)
      local e = angle + math.rad(5)
      local d = distanceBetween(o.planet.body:getX(), o.planet.body:getY(), player.body:getX(), player.body:getY())

      if d < r then
        -- If (starting angle is less than ending angle and the point is within that arc)
        -- or (starting angle is greater than ending angle (we are encompassing zero in the arc) and the angle of the point is within the starting and ending angle)
        if (s < e and (s < a and a < e)) or (s > e and (a > s or a < e)) then
          ping = { 
            x = o.planet.body:getX(),
            y = o.planet.body:getY(),
            sector = math.floor(o.planet.body:getX()/2000 - 250) .. ':' .. math.floor(o.planet.body:getY()/2000 - 250),
            data = 'Ping! Body found within scanner range of range: ' .. r .. ' at ' .. math.floor(d) 
            .. '. Scanner sweep at 10 degrees from ' .. math.floor(math.deg(s)) .. ' to ' 
            .. math.floor(math.deg(e)) .. ' identified a target vector of ' .. math.floor(math.deg(a))
            .. '. Target is in sector ' .. math.floor(o.planet.body:getX()/2000 - 250) .. ':' .. math.floor(o.planet.body:getY()/2000 - 250) .. '. Press I to isolate the signal for warp.'
          }
          
          table.insert(player.scannerData, ping)
        end
      end
    end
  end
end

function isolateScanTarget(x, y, cushion)
  player.warpTargetX = x + cushion
  player.warpTargetY = y + cushion
  player.warpReady = true
end

function warp()
  player.body:setX(player.warpTargetX)
  player.body:setY(player.warpTargetY)
  player.warpReady = false
  player.warpTargetX = 0
  player.warpTargetY = 0
  player.scannerData = {}
end