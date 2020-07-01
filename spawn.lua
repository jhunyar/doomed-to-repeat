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

function spawnLoot()
  loot = {}

  loot.x = math.random(0, mapw)
  loot.y = math.random(0, maph)
  loot.type = 'ammo'
  loot.claimed = false

  table.insert(loots, loot)
end

function spawnPlanet(x, y, size)
  planet = {}

  planet.body = love.physics.newBody(myWorld, x, y, 'static')
  planet.shape = love.physics.newCircleShape(size/2)
  planet.fixture = love.physics.newFixture(planet.body, planet.shape)

  planet.x = x
  planet.y = y
  planet.size = size
  planet.owner = 'none'

  -- planet.grid = anim8.newGrid(256, 256, 2560, 2304)
  -- planet.animation = anim8.newAnimation(planet.grid('1-10',1, '1-10',2, '1-10',3, '1-10',4, '1-10',5, '1-10',6, '1-10',7, '1-10',8, '1-10',9), 0.1)

  table.insert(planets, planet)
end