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
  for i,z in ipairs(enemies) do
    if distanceBetween(z.x, z.y, z.wx, z.wy) < 50 then -- enemy has arrived
      nx, ny = genWaypoint(z)
      z.wx = nx
      z.wy = ny
    end
  
    -- track the player if too close
    if distanceBetween(z.x, z.y, player.body:getX(), player.body:getY()) < 500 then
      z.angle = enemy_player_angle(z)
      z.x = z.x + math.cos(enemy_player_angle(z)) * z.speed * dt
      z.y = z.y + math.sin(enemy_player_angle(z)) * z.speed * dt
    else -- move enemy towards waypoint
      z.angle = enemy_waypoint_angle(z)
      z.x = z.x + math.cos(enemy_waypoint_angle(z)) * z.speed * dt
      z.y = z.y + math.sin(enemy_waypoint_angle(z)) * z.speed * dt
    end
    
    if distanceBetween(z.x, z.y, player.body:getX(), player.body:getY()) < 30 then
      enemies = {}
      loots = {}
      bullets = {}
      gameState = 1
      music:stop()
      ending:play()
      player.body:setPosition(mapw/2, maph/2)
      cam:lookAt(mapw/2, maph/2)
    end

    if distanceBetween(z.x, z.y, player.body:getX(), player.body:getY()) < 100 then
      player.fear = player.fear + 3 * dt
    elseif distanceBetween(z.x, z.y, player.body:getX(), player.body:getY()) < 200 then
      player.fear = player.fear + 2 * dt
    elseif distanceBetween(z.x, z.y, player.body:getX(), player.body:getY()) < 300 then
      player.fear = player.fear + 1 * dt
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

  for i=#enemies, 1, -1 do
    local z = enemies[i]
    if z.dead == true then
      table.remove(enemies, i)
    end
  end
end

function drawEnemies()
  for i,z in ipairs(enemies) do
    love.graphics.draw(sprites.enemy, z.x, z.y, z.angle, 1, 1, sprites.enemy:getWidth()/2, sprites.enemy:getHeight()/2)
  end
end

function genWaypoint(e)
  if e.x <= 0 then
    wx = e.x + math.random(30,500)
  elseif e.x >= mapw then
    wx = e.x + math.random(-30,-500)
  else
    wx = e.x + math.random(-500, 500)
  end

  if e.y <= 0 then
    wy = e.y + math.random(30,500)
  elseif e.y >= maph then
    wy = e.y + math.random(-30,-500)
  else
    wy = e.y + math.random(-500, 500)
  end

  return wx, wy
end
