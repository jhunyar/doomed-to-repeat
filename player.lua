sti = require('sti/sti')
gameMap = sti('maps/map-lg.lua')

mapw = gameMap.width * gameMap.tilewidth
maph = gameMap.height * gameMap.tileheight

player = {}
player.body = love.physics.newBody(myWorld, mapw/2, maph/2, 'dynamic')
player.shape = love.physics.newRectangleShape(90, 90)
player.fixture = love.physics.newFixture(player.body, player.shape)

player.linearDampingStatus = 'OFF'
player.linearDamping = 0
player.thrust = 100
player.maxSpeed = 600
player.maxTorque = 10^5

player.maxFear = 100
player.fear = 0
player.maxAmmo = 100
player.ammo = 100
player.panicFireRate = 0.10
player.sprite = sprites.shipStatic

player.body:setMass(500)
player.body:setLinearDamping(player.linearDamping)
-- player.body:setFixedRotation(true)

function updatePlayer(dt)
  if gameState == 2 then
    if player.body:getY() > maph or player.body:getY() < 0 or player.body:getX() < 0 or player.body:getX() > mapw then
      player.body:setLinearDamping(1.5)
    else
      player.body:setLinearDamping(player.linearDamping)
    end
  
    if love.keyboard.isDown('s') and player.body:getY() < maph then -- and player.body:getY() < love.graphics.getHeight()
      player.body:applyForce(0, player.thrust*1000)
      if player.body:getAngle() > 3.93 and player.body:getAngle() < 5.5 then
        player.sprite = sprites.shipFront
      elseif player.body:getAngle() < 3.93 and player.body:getAngle() > 2.36 then
        player.sprite = sprites.shipRight
      elseif player.body:getAngle() < 2.36 and player.body:getAngle() > 0.79 then
        player.sprite = sprites.shipRear
      else
        player.sprite = sprites.shipLeft
      end
    end

    if love.keyboard.isDown('w') and player.body:getY() > 0 then -- and player.body:getY() > 0
      player.body:applyForce(0, -player.thrust*1000)
      if player.body:getAngle() > 3.93 and player.body:getAngle() < 5.5 then
        player.sprite = sprites.shipRear
      elseif player.body:getAngle() < 3.93 and player.body:getAngle() > 2.36 then
        player.sprite = sprites.shipLeft
      elseif player.body:getAngle() < 2.36 and player.body:getAngle() > 0.79 then
        player.sprite = sprites.shipFront
      else
        player.sprite = sprites.shipRight
      end
    end

    if love.keyboard.isDown('a') and player.body:getX() > 0 then -- and player.body:getX() > 0
      player.body:applyForce(-player.thrust*1000, 0)
      if player.body:getAngle() > 3.93 and player.body:getAngle() < 5.5 then
        player.sprite = sprites.shipRight
      elseif player.body:getAngle() < 3.93 and player.body:getAngle() > 2.36 then
        player.sprite = sprites.shipRear
      elseif player.body:getAngle() < 2.36 and player.body:getAngle() > 0.79 then
        player.sprite = sprites.shipLeft
      else
        player.sprite = sprites.shipFront
      end
    end

    if love.keyboard.isDown('d') and player.body:getX() < mapw then -- and player.body:getX() < love.graphics.getWidth()
      player.body:applyForce(player.thrust*1000, 0)
      if player.body:getAngle() > 3.93 and player.body:getAngle() < 5.5 then
        player.sprite = sprites.shipLeft
      elseif player.body:getAngle() < 3.93 and player.body:getAngle() > 2.36 then
        player.sprite = sprites.shipFront
      elseif player.body:getAngle() < 2.36 and player.body:getAngle() > 0.79 then
        player.sprite = sprites.shipRight
      else
        player.sprite = sprites.shipRear
      end
    end

    updateTorque()

    -- if player.body:getAngle() < player_mouse_angle() then
    --   player.body:applyTorque((player.body:getAngle() - player_mouse_angle()) * player.maxSpeed)
    -- elseif player.body:getAngle() > player_mouse_angle() then
    --   player.body:applyTorque((player.body:getAngle() - player_mouse_angle()) * player.maxSpeed)
    -- end

    local vx, vy = player.body:getLinearVelocity()
    vx, vy = clamp(vx, vy, player.maxSpeed)
    player.body:setLinearVelocity(vx, vy)

    for i,l in ipairs(loots) do
      if distanceBetween(l.x, l.y, player.body:getX(), player.body:getY()) < 30 then
        if l.type == 'ammo' then
          player.ammo = player.ammo + 20
        end
        
        l.claimed = true
      end
    end

    for i,p in ipairs(planets) do
      gravityWell(player.body, p.x, p.y, p.size*10, p.size*4) -- body, x, y, power, epsilon
    end

    if player.fear > player.maxFear then
      player.panicFireRate = player.panicFireRate - dt
      if player.panicFireRate <= 0 and player.ammo > 0 then
        spawnBullet()

        player.panicFireRate = 0.10
      end
    end

    if player.fear > 0 then
      player.fear = player.fear - 2 * dt
    end

    if player.fear < 0 then
      player.fear = 0
    end
  end
end

function drawPlayer()
  love.graphics.draw(player.sprite, player.body:getX(), player.body:getY(), player.body:getAngle(), 1, 1, sprites.player:getWidth()/2, sprites.player:getHeight()/2)
end

function quantumLeap()
  local instance = sndLeap:play()
  x,y = cam:mousePosition()
  player.body:setPosition(player.body:getX() + 350 * math.cos(math.atan2(player.body:getY() - y, player.body:getX() - x) + math.pi), player.body:getY() + 350 * math.sin(math.atan2(player.body:getY() - y, player.body:getX() - x) + math.pi))
end

function spawnBullet()
  local instance = sndShoot:play()

  bullet = {}

  bullet.x = player.body:getX()
  bullet.y = player.body:getY()
  bullet.speed = 1000
  bullet.direction = player_mouse_angle()
  bullet.dead = false

  table.insert(bullets, bullet)

  player.ammo = player.ammo - 1
end

function updateBullets(dt)
  for i,b in ipairs(bullets) do
    b.x = b.x + math.cos(b.direction) * b.speed * dt
    b.y = b.y + math.sin(b.direction) * b.speed * dt
  end
end

function updateTorque()
  local twoPi = 2.0 * math.pi -- small optimisation 

  -- returns -1, 1 or 0 depending on whether x>0, x<0 or x=0
  function sign(x)
    return x>0 and 1 or x<0 and -1 or 0
  end

  -- transforms any angle so it is on the 0-2Pi range
  local _normalizeAngle = function(angle)
    angle = angle % twoPi
    return (angle < 0 and (angle + twoPi) or angle)
  end

  local tx, ty = cam:mousePosition()
  local x, y = player.body:getPosition()
  local angle = player.body:getAngle()
  local maxTorque = player.maxTorque
  local inertia = player.body:getInertia()
  local w = player.body:getAngularVelocity()

  local targetAngle = math.atan2(ty-y,tx-x)

  -- distance I have to cover
  local differenceAngle = _normalizeAngle(targetAngle - angle)

  -- distance it will take me to stop
  local brakingAngle = _normalizeAngle(sign(w)*2.0*w*w*inertia/maxTorque)

  local torque = maxTorque

  -- two of these 3 conditions must be true
  local a,b,c = differenceAngle > math.pi, brakingAngle > differenceAngle, w > 0
  if( (a and b) or (a and c) or (b and c) ) then
    torque = -torque
  end

  player.body:applyTorque(torque)

  fltAngle = player.body:getAngle() % (2*math.pi)
  player.body:setAngle(fltAngle)
end