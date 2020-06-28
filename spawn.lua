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

function spawnBullet()
  local instance = sndShoot:play()

  bullet = {}

  bullet.x = player.body:getX()
  bullet.y = player.body:getY()
  bullet.speed = 500
  bullet.direction = player_mouse_angle()
  bullet.dead = false

  table.insert(bullets, bullet)

  player.ammo = player.ammo - 1
end

function spawnLoot()
  loot = {}

  loot.x = math.random(0, mapw)
  loot.y = math.random(0, maph)
  loot.type = 'ammo'
  loot.claimed = false

  table.insert(loots, loot)
end