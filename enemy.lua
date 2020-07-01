function spawnEnemy()
  enemy = {}

  enemy.x = 0
  enemy.y = 0
  enemy.sx = 0
  enemy.sy = 0
  enemy.wx = 0
  enemy.wy = 0
  enemy.angle = 0
  enemy.speed = 140
  enemy.dead = false
  enemy.arrived = false

  local side = math.random(1, 4)

  if side == 1 then
    enemy.x = -30
    enemy.sx = -30
    enemy.y = math.random(0, maph)
    enemy.sy = math.random(0, maph)
  elseif side == 2 then
    enemy.x = math.random(0, mapw)
    enemy.sx = math.random(0, mapw)
    enemy.y = -30
    enemy.sy = -30
  elseif side == 3 then
    enemy.x = mapw + 30
    enemy.sx = mapw + 30
    enemy.y = math.random(0, maph)
    enemy.sy = math.random(0, maph)
  else
    enemy.x = math.random(0, mapw)
    enemy.sx = math.random(0, mapw)
    enemy.y = maph + 30
    enemy.sy = maph + 30
  end

  enemy.wx, enemy.wy = genWaypoint(enemy)

  table.insert(enemies, enemy)
end


function updateEnemies(dt)
  for i,e in ipairs(enemies) do
    if distanceBetween(e.x, e.y, e.wx, e.wy) < 50 then -- enemy has arrived in vicinity of waypoint
      nx, ny = genWaypoint()
      e.wx = nx
      e.wy = ny
    end

    -- check for habitable worlds
    planetInRange = false
    targetPlanet = {}
    --
    for j,p in ipairs(planets) do
      if distanceBetween(e.x, e.y, p.x + p.size/2, p.y + p.size/2) < 300 then
        planetInRange = true
        targetPlanet = p
      end
    end
    
    -- track the player if too close
    if distanceBetween(e.x, e.y, player.body:getX(), player.body:getY()) < 200 then
      e.angle = enemy_player_angle(e)
      e.x = e.x + math.cos(e.angle) * e.speed * dt
      e.y = e.y + math.sin(e.angle) * e.speed * dt
    elseif planetInRange and (targetPlanet.owner == 'player' or targetPlanet.owner == 'none') then
      e.angle = getAngle(e, targetPlanet)
      e.x = e.x + math.cos(e.angle) * e.speed * dt
      e.y = e.y + math.sin(e.angle) * e.speed * dt
    else -- move enemy towards waypoint
      e.angle = enemy_waypoint_angle(e)
      e.x = e.x + math.cos(e.angle) * e.speed * dt
      e.y = e.y + math.sin(e.angle) * e.speed * dt
    end

    if distanceBetween(e.x, e.y, player.body:getX(), player.body:getY()) < 30 then
      enemies = {}
      loots = {}
      bullets = {}
      gameState = 1
      music:stop()
      ending:play()
      player.body:setPosition(mapw/2, maph/2)
      cam:lookAt(mapw/2, maph/2)
    end

    if distanceBetween(e.x, e.y, player.body:getX(), player.body:getY()) < 100 then
      player.fear = player.fear + 3 * dt
    elseif distanceBetween(e.x, e.y, player.body:getX(), player.body:getY()) < 200 then
      player.fear = player.fear + 2 * dt
    elseif distanceBetween(e.x, e.y, player.body:getX(), player.body:getY()) < 300 then
      player.fear = player.fear + 1 * dt
    end
  end

  for i,e in ipairs(enemies) do
    for j,b in ipairs(bullets) do
      if distanceBetween(e.x, e.y, b.x, b.y) < 20 then
        sndDestroy:play()
        e.dead = true
        b.dead = true
        score = score + 1
        player.ammo = player.ammo + 1
      end
    end
  end

  for i=#enemies, 1, -1 do
    local e = enemies[i]
    if e.dead == true then
      table.remove(enemies, i)
    end
  end
end

function drawEnemies()
  for i,e in ipairs(enemies) do
    love.graphics.draw(sprites.enemy, e.x, e.y, e.angle, 1, 1, sprites.enemy:getWidth()/2, sprites.enemy:getHeight()/2)
  end
end

function genWaypoint()
  wx = math.random(0,mapw)
  wy = math.random(0,maph)
  return wx, wy
end

function planetInRange(e)
  for i,p in ipairs(planets) do
    if p.owner == 'player' or p.owner == 'none' and distanceBetween(e.x, e.y, p.x + p.size/2, p.y + p.size/2) < 500 then
      
    end
  end
end

