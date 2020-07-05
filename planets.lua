function spawnPlanet(x, y, size)
  planet = {}

  orbit = {}
  for i=1, 3, 1 do
    moon = love.math.random(0, 1)
    radius = size * love.math.random((i + 1) * love.math.random(1.2, 2))
    table.insert(orbit, moon, radius)
  end
  table.insert(planet.orbits, orbit)

  planet.body = love.physics.newBody(myWorld, x, y, 'static')
  planet.shape = love.physics.newCircleShape(size/2)
  planet.fixture = love.physics.newFixture(planet.body, planet.shape)

  planet.size = size
  planet.discovered = false
  planet.owner = 'none'

  function spawnMoon(orbit)
    moon = {}
  
    moon.angle = math.rad(love.math.random(0, 360))
    planet.orbit = orbit
    moon.orbit = size * love.math.random(2, 4)
    moon.size = math.floor(love.math.random(400, 1000))
    moon.discovered = false
    moon.owner = 'none'

    moon.body = love.physics.newBody(myWorld, x + moon.orbit * math.cos(moon.angle), y + moon.orbit * math.sin(moon.angle), 'static')
    moon.shape = love.physics.newCircleShape(moon.size/2)
    moon.fixture = love.physics.newFixture(moon.body, moon.shape)
  

    moons = {}
    orbits = {}

    tableinsert(moons, moon)
    table.insert(orbits, moons)
    table.insert(planet, orbits)
  end

  for i=1, #planet.orbits, 1 do
    if planet.orbits[i].moon == 1 then
      spawnMoon(planet.orbits[i].radius)
    end
  end
  -- planet.grid = anim8.newGrid(256, 256, 2560, 2304)
  -- planet.animation = anim8.newAnimation(planet.grid('1-10',1, '1-10',2, '1-10',3, '1-10',4, '1-10',5, '1-10',6, '1-10',7, '1-10',8, '1-10',9), 0.1)

  table.insert(planets, planet)
end

function updatePlanets()
  -- enemy claims planet
  for i,p in ipairs(planets) do
    if distanceBetween(p.body:getX(), p.body:getY(), player.body:getX(), player.body:getY()) < p.size/2 + 1000 then
      p.discovered = true
      -- if p.moon == 1 then p.moonDiscovered = true end
    end

    for j,m in ipairs(p.moons) do
      m.discovered = true -- TODO remove
      if distanceBetween(m.body:getX(), m.body:getY(), player.body:getX(), player.body:getY()) < m.size/2 + 700 then
        m.discovered = true
      end
    end

    for k,e in ipairs(enemies) do    -- enemy claims planet
      if distanceBetween(e.x, e.y, p.body:getX(), p.body:getY()) < p.size/2 then
        p.owner = 'enemy'
      end
    end
  end
end

function drawPlanets()
  for i,p in ipairs(planets) do
    -- p.animation:draw(sprites.planetAnim, p.body:getX(), p.body:getY(), nil, p.size/260, p.size/260, 128, 128)

    if p.size > 500 then
      love.graphics.draw(sprites.planetLg, p.body:getX(), p.body:getY(), nil, p.size/sprites.planetLg:getWidth(), p.size/sprites.planetLg:getWidth(), sprites.planetLg:getWidth()/2, sprites.planetLg:getHeight()/2)
    else
      love.graphics.draw(sprites.planets[i], p.body:getX(), p.body:getY(), nil, p.size/sprites.planets[i]:getWidth(), p.size/sprites.planets[i]:getWidth(), sprites.planets[i]:getWidth()/2, sprites.planets[i]:getHeight()/2)
    end
    if p.owner == 'player' then
      love.graphics.setColor(0,0.2,1)
      love.graphics.rectangle( 'fill', p.body:getX()-100, p.body:getY()-100, 200, 200 )
      love.graphics.setColor(1,1,1)
    elseif p.owner == 'enemy' then
      love.graphics.setColor(1,0,0)
      love.graphics.rectangle( 'fill', p.body:getX()-100, p.body:getY()-100, 200, 200 )
      love.graphics.setColor(1,1,1)
    end

    for j,m in ipairs(p.moons) do
      if p.discovered == true then
        love.graphics.setColor(1,1,1,0.3)
        love.graphics.circle('line', p.body:getX(), p.body:getY(), distanceBetween(p.body:getX(), p.body:getY(), m.body:getX(), m.body:getY()))
        love.graphics.setColor(1,1,1)
      end
      -- TODO find out why I can't use [i] here anymore without breaking the game
      love.graphics.draw(sprites.moons[1], m.body:getX(), m.body:getY(), nil, m.size/sprites.moons[1]:getWidth(), m.size/sprites.moons[1]:getHeight(), sprites.moons[1]:getWidth()/2, sprites.moons[1]:getHeight()/2)
    end
  end
end