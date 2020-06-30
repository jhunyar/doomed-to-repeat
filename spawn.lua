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