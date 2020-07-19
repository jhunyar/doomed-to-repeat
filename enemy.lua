function spawnEnemy()
  enemy = {}

  enemy.x = 0
  enemy.y = 0
  enemy.sx = 0
  enemy.sy = 0
  enemy.wx = 0
  enemy.wy = 0
  enemy.angle = 0
  enemy.speed = 1000
  enemy.dead = false
  enemy.arrived = false
  enemy.health = 3

  enemy.x = love.math.random(0, mapw)
  enemy.y = love.math.random(0, maph)
  enemy.sx = love.math.random(0, mapw)
  enemy.sy = love.math.random(0, maph)

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
    for j,o in ipairs(star.orbits) do
      if o.planet then
        if distanceBetween(e.x, e.y, o.planet.body:getX() + o.planet.size/2, o.planet.body:getY() + o.planet.size/2) < 100000 then
          planetInRange = true
          targetPlanet = o.planet
        end
      end
    end

    -- track the player if too close
    if distanceBetween(e.x, e.y, player.body:getX(), player.body:getY()) < 300 then
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
      for i,o in ipairs(star.orbits) do
        if o.planet then
          o.planet.owner = 'none'
          o.planet.discovered = false
        end
      end
      enemies = {}
      loots = {}
      bullets = {}
      gameState = 1
      playSound(explosionLong)
      local angle = math.rad(love.math.random(0, 360))
      local playerX = star.body:getX() + star.size * math.cos(angle)
      local playerY = star.body:getY() + star.size * math.sin(angle)
      spawnPlayer(playerX, playerY)
      -- cam:lookAt(player.body:getX(), player.body:getY())
    end
  end

  for i,e in ipairs(enemies) do
    if e.health == 0 then
      e.dead = true
      score = score + 1
      player.ammo = player.ammo + 1
    end

    for j,b in ipairs(bullets) do
      if distanceBetween(e.x, e.y, b.x, b.y) < 20 then
        playSound(sndDestroy)
        if e.health > 0 then
          e.health = e.health - 1
        end
        b.dead = true
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
  wx = love.math.random(0,mapw)
  wy = love.math.random(0,maph)
  return wx, wy
end