function spawnPlanet(x, y, size)
  planet = {}

  planet.body = love.physics.newBody(myWorld, x, y, 'static')
  planet.shape = love.physics.newCircleShape(size/2)
  planet.fixture = love.physics.newFixture(planet.body, planet.shape)

  planet.x = x
  planet.y = y
  planet.size = size
  planet.discovered = false
  planet.owner = 'none'

  -- planet.grid = anim8.newGrid(256, 256, 2560, 2304)
  -- planet.animation = anim8.newAnimation(planet.grid('1-10',1, '1-10',2, '1-10',3, '1-10',4, '1-10',5, '1-10',6, '1-10',7, '1-10',8, '1-10',9), 0.1)

  table.insert(planets, planet)
end

function updatePlanets()
  -- enemy claims planet
  for i,p in ipairs(planets) do
    if distanceBetween(p.x, p.y, player.body:getX(), player.body:getY()) < 1000 then
      p.discovered = true
    end

    for j,e in ipairs(enemies) do    -- enemy claims planet
      if distanceBetween(e.x, e.y, p.x, p.y) < p.size/2 then
        p.owner = 'enemy'
      end
    end
  end
end