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

function drawPlanets()
  for i,p in ipairs(planets) do
    -- p.animation:draw(sprites.planetAnim, p.x, p.y, nil, p.size/260, p.size/260, 128, 128)

    if p.size > 500 then
      love.graphics.draw(sprites.planetLg, p.x, p.y, nil, p.size/sprites.planetLg:getWidth(), p.size/sprites.planetLg:getWidth(), sprites.planetLg:getWidth()/2, sprites.planetLg:getHeight()/2)
    else
      love.graphics.draw(sprites.planets[i], p.x, p.y, nil, p.size/sprites.planets[i]:getWidth(), p.size/sprites.planets[i]:getWidth(), sprites.planets[i]:getWidth()/2, sprites.planets[i]:getHeight()/2)
    end
    if p.owner == 'player' then
      love.graphics.setColor(0,0.2,1)
      love.graphics.rectangle( 'fill', p.x-10, p.y-10, 20, 20 )
      love.graphics.setColor(1,1,1)
    elseif p.owner == 'enemy' then
      love.graphics.setColor(1,0,0)
      love.graphics.rectangle( 'fill', p.x-10, p.y-10, 20, 20 )
      love.graphics.setColor(1,1,1)
    end
  end
end