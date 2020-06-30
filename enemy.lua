function spawnEnemy()
  enemy = {}

  enemy.x = 0
  enemy.y = 0
  enemy.speed = 140
  enemy.dead = false

  local side = math.random(1, 4)

  if side == 1 then
    enemy.x = -30
    enemy.y = math.random(0, maph)
  elseif side == 2 then
    enemy.x = math.random(0, mapw)
    enemy.y = -30
  elseif side == 3 then
    enemy.x = mapw + 30
    enemy.y = math.random(0, maph)
  else
    enemy.x = math.random(0, mapw)
    enemy.y = maph + 30
  end

  table.insert(enemies, enemy)
end


function updateEnemies(dt)
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
    love.graphics.draw(sprites.enemy, z.x, z.y, enemy_player_angle(z), 1, 1, sprites.enemy:getWidth()/2, sprites.enemy:getHeight()/2)
  end
end