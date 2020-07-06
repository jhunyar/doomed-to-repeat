function spawnSolarSystem(x, y, size)
  star = {}
  star.orbits = {}

  star.size = size
  star.body = love.physics.newBody(myWorld, x, y, 'static')
  star.shape = love.physics.newCircleShape(size/2)
  star.fixture = love.physics.newFixture(star.body, star.shape)
   
  star.body:setMass(size)

  -- create orbits for this star
  local minOrbitRadius = star.size/2 + 50000 -- not too close to the star as it will eventually kill the player
  local maxOrbitRadius = mapw/2 - star.size/2 - 20000 -- assuming the star is always at the center of the map here
  local maxOrbits = 20
  local orbitSeparation = (maxOrbitRadius - minOrbitRadius) / maxOrbits -- assuming 420000/20 = 21,000
  
  for i=minOrbitRadius, maxOrbitRadius, orbitSeparation do
    orbit = {}
    orbit.radius = i
    orbit.speed = love.math.random(50, 100)
    orbit.hasPlanet = love.math.random(0, 1)

    spawnPlanet(orbit)
    table.insert(star.orbits, orbit)
  end
end

function spawnPlanet(orbit)
  if orbit.hasPlanet == 1 then
    orbit.planet = {}
    local p = orbit.planet
    p.orbits = {}
    p.size = love.math.random(1000, 2000)
    p.angle = math.rad(love.math.random(0, 360))
    p.discovered = false
    p.owner = 'none'

    local pX = star.body:getX() + orbit.radius * math.cos(p.angle)
    local pY = star.body:getY() + orbit.radius * math.sin(p.angle)

    p.body = love.physics.newBody(myWorld, pX, pY, 'static')
    p.shape = love.physics.newCircleShape(p.size/2)
    p.fixture = love.physics.newFixture(p.body, p.shape)
    
    -- create orbits for this planet
    local minOrbitRadius = p.size/2 + 3000
    local maxOrbitRadius = p.size/2 + 6000
    local maxOrbits = 3
    local orbitSeparation = (maxOrbitRadius - minOrbitRadius) / maxOrbits -- assuming 420000/20 = 21,000

    for i=minOrbitRadius, maxOrbitRadius, orbitSeparation do
      orbit = {}
  
      orbit.radius = i
      orbit.speed = love.math.random(50, 100)
      orbit.hasMoon = love.math.random(0, 1)
  
      spawnMoon(p, orbit)
      table.insert(p.orbits, orbit)
    end
  end
end

function spawnMoon(planet, orbit)
  if orbit.hasMoon == 1 then
    orbit.moon = {}
    local m = orbit.moon
    m.size = love.math.random(250, 500)
    m.angle = math.rad(love.math.random(0, 360))
    m.discovered = false
    m.owner = 'none'

    local mX = planet.body:getX() + orbit.radius * math.cos(m.angle)
    local mY = planet.body:getY() + orbit.radius * math.sin(m.angle)

    m.body = love.physics.newBody(myWorld, mX, mY, 'static')
    m.shape = love.physics.newCircleShape(m.size/2)
    m.fixture = love.physics.newFixture(m.body, m.shape)
  end
end

-- Every dt, we need to update the positon of planets and moons in the solar system
function updatePlanets(dt)
  for i,o in ipairs(star.orbits) do
    if o.planet then
      local r = o.radius
      local a = o.planet.angle
      o.planet.angle = o.planet.angle + dt * (500000-r) * 0.00000001

      local ox = star.body:getX()
      local oy = star.body:getY()

      o.planet.body:setX(o.radius * math.cos(o.planet.angle) + ox)
      o.planet.body:setY(o.radius * math.sin(o.planet.angle) + oy)

      -- player can discover the planet on minimap
      if distanceBetween(o.planet.body:getX(), o.planet.body:getY(), player.body:getX(), player.body:getY()) < o.planet.size/2 + 1000 then
        o.planet.discovered = true
      end
      

      if player.landed == true and distanceBetween(o.planet.body:getX(), o.planet.body:getY(), player.body:getX(), player.body:getY()) < o.planet.size/2 + 50 then
        player.joint = love.physics.newWeldJoint(
          player.body, o.planet.body,
          player.body:getX(), player.body:getY()
        )
      end

      -- enemy can claim the planet
      for j,e in ipairs(enemies) do    -- enemy claims planet
        if distanceBetween(e.x, e.y, o.planet.body:getX(), o.planet.body:getY()) < o.planet.size/2 then
          o.planet.owner = 'enemy'
        end
      end

      updateMoons(o.planet, dt)
    end
  end
end

function updateMoons(planet, dt)
  for i,o in ipairs(planet.orbits) do
    if o.moon then
      local r = o.radius
      local a = o.moon.angle
      o.moon.angle = o.moon.angle + dt * (500000-r) * 0.00000001

      local px = planet.body:getX()
      local py = planet.body:getY()

      o.moon.body:setX(o.radius * math.cos(o.moon.angle) + px)
      o.moon.body:setY(o.radius * math.sin(o.moon.angle) + py)

      -- player can discover the moon on minimap
      if distanceBetween(o.moon.body:getX(), o.moon.body:getY(), player.body:getX(), player.body:getY()) < o.moon.size/2 + 1000 then
        o.moon.discovered = true
      end

      if player.landed == true and distanceBetween(o.moon.body:getX(), o.moon.body:getY(), player.body:getX(), player.body:getY()) < o.moon.size/2 + 50 then
        player.moonJoint = love.physics.newWeldJoint(
          player.body, o.moon.body,
          player.body:getX(), player.body:getY()
        )
      end

      -- enemy can claim the moon
      for j,e in ipairs(enemies) do    -- enemy claims planet
        if distanceBetween(e.x, e.y, o.moon.body:getX(), o.moon.body:getY()) < o.moon.size/2 then
          o.moon.owner = 'enemy'
        end
      end
    end
  end
end

-- every dt, we need to draw the planets
function drawPlanets()
  love.graphics.setColor(1, 1, 0)
  love.graphics.circle('fill', star.body:getX(), star.body:getY(), star.size/2)
  love.graphics.setColor(1, 1, 1)

  for i,o in ipairs(star.orbits) do  
    if o.planet then
      love.graphics.draw(sprites.planetLg, o.planet.body:getX(), o.planet.body:getY(), nil, o.planet.size/sprites.planetLg:getWidth(), o.planet.size/sprites.planetLg:getWidth(), sprites.planetLg:getWidth()/2, sprites.planetLg:getHeight()/2)

      love.graphics.setLineWidth(2)
      if o.planet.owner == 'player' then
        love.graphics.setColor(0,0.2,1)
      elseif o.planet.owner == 'enemy' then
        love.graphics.setColor(1,0.2,0)
      end

      love.graphics.circle('line', o.planet.body:getX(), o.planet.body:getY(), o.planet.size/2)
      love.graphics.setColor(1,1,1)
      love.graphics.setLineWidth(1)

      drawMoons(o.planet)
    end
  end
end

function drawMoons(planet)
  for i,o in ipairs(planet.orbits) do  
    if o.moon then
      love.graphics.draw(sprites.moons[1], o.moon.body:getX(), o.moon.body:getY(), nil, o.moon.size/sprites.moons[1]:getWidth(), o.moon.size/sprites.moons[1]:getWidth(), sprites.moons[1]:getWidth()/2, sprites.moons[1]:getHeight()/2)

      love.graphics.setLineWidth(2)
      if o.moon.owner == 'player' then
        love.graphics.setColor(0,0.2,1)
      elseif o.moon.owner == 'enemy' then
        love.graphics.setColor(1,0.2,0)
      end

      love.graphics.circle('line', o.moon.body:getX(), o.moon.body:getY(), o.moon.size/2)
      love.graphics.setColor(1,1,1)
      love.graphics.setLineWidth(1)
    end
  end
end