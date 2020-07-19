local fontMd = love.graphics.newFont(20)

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
  local minOrbits = 6
  local maxOrbits = 10
  local totalOrbits = love.math.random(minOrbits, maxOrbits)
  local orbitSeparation = (maxOrbitRadius - minOrbitRadius) / totalOrbits
  
  for i=minOrbitRadius, maxOrbitRadius, orbitSeparation do
    orbit = {}
    orbit.radius = math.random(i - 10000, i + 10000)
    -- orbit.speed = love.math.random(50, 100)

    spawnPlanet(orbit)
    table.insert(star.orbits, orbit)
  end
end

function spawnPlanet(orbit)
  orbit.planet = {}
  local p = orbit.planet
  p.orbits = {}
  p.size = love.math.random(1000, 2000)
  p.angle = math.rad(love.math.random(0, 360))
  p.discovered = false
  p.owner = 'none'
  p.startingRes = math.floor(p.size / 2)
  p.res = p.startingRes
  p.harvestedRes = 0

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
    orbit.hasMoon = love.math.random(0, 1)

    spawnMoon(p, orbit)
    table.insert(p.orbits, orbit)
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
    m.startingRes = math.floor(m.size / 2)
    m.res = m.startingRes
    m.harvestedRes = 0

    local mX = planet.body:getX() + orbit.radius * math.cos(m.angle)
    local mY = planet.body:getY() + orbit.radius * math.sin(m.angle)

    m.body = love.physics.newBody(myWorld, mX, mY, 'static')
    m.shape = love.physics.newCircleShape(m.size/2)
    m.fixture = love.physics.newFixture(m.body, m.shape)
  end
end

timeFactor = 0.00000001
-- Every dt, we need to update the positon of planets and moons in the solar system
function updatePlanets(dt)
  for i,o in ipairs(star.orbits) do
    if o.planet then
      -- do this first otherwise the planet has already moved before landing
      if player.landed == true and distanceBetween(o.planet.body:getX(), o.planet.body:getY(), player.body:getX(), player.body:getY()) < o.planet.size/2 + 50 then
        player.joint = love.physics.newWeldJoint(
          player.body, o.planet.body,
          player.body:getX(), player.body:getY()
        )

        o.planet.owner = 'player'
      end

      local r = o.radius
      local a = o.planet.angle
      o.planet.angle = o.planet.angle + dt * (500000-r) * timeFactor

      local ox = star.body:getX()
      local oy = star.body:getY()

      o.planet.body:setX(o.radius * math.cos(o.planet.angle) + ox)
      o.planet.body:setY(o.radius * math.sin(o.planet.angle) + oy)

      -- player can discover the planet on minimap
      if distanceBetween(o.planet.body:getX(), o.planet.body:getY(), player.body:getX(), player.body:getY()) < o.planet.size/2 + 1000 then
        o.planet.discovered = true
      end

      -- enemy can claim the planet
      for j,e in ipairs(enemies) do    -- enemy claims planet
        if distanceBetween(e.x, e.y, o.planet.body:getX(), o.planet.body:getY()) < o.planet.size/2 then
          o.planet.owner = 'enemy'
        end
      end

      if o.planet.owner == 'player' then
        if o.planet.res > 0 then
          o.planet.res = o.planet.res - dt -- 1 per second
          o.planet.harvestedRes = o.planet.harvestedRes + dt
        end
      end

      updateMoons(o.planet, dt)
    end
  end
end

function updateMoons(planet, dt)
  for i,o in ipairs(planet.orbits) do
    if o.moon then
      -- do this first otherwise the moon has already moved before landing
      if player.landed == true and distanceBetween(o.moon.body:getX(), o.moon.body:getY(), player.body:getX(), player.body:getY()) < o.moon.size/2 + 50 then
        player.moonJoint = love.physics.newWeldJoint(
          player.body, o.moon.body,
          player.body:getX(), player.body:getY()
        )

        o.moon.owner = 'player'
      end

      local r = o.radius
      local a = o.moon.angle
      o.moon.angle = o.moon.angle + dt * (500000-r) * timeFactor * 10

      local px = planet.body:getX()
      local py = planet.body:getY()

      o.moon.body:setX(o.radius * math.cos(o.moon.angle) + px)
      o.moon.body:setY(o.radius * math.sin(o.moon.angle) + py)

      -- player can discover the moon on minimap
      if distanceBetween(o.moon.body:getX(), o.moon.body:getY(), player.body:getX(), player.body:getY()) < o.moon.size/2 + 1000 then
        o.moon.discovered = true
      end

      -- enemy can claim the moon
      for j,e in ipairs(enemies) do    -- enemy claims moon
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
      if o.planet.discovered == true then
        love.graphics.setColor(1,1,1,0.3)
        love.graphics.circle('line', star.body:getX(), star.body:getY(), distanceBetween(star.body:getX(), star.body:getY(), o.planet.body:getX(), o.planet.body:getY()))
        love.graphics.setColor(1,1,1)
      end
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

      if distanceBetween(o.planet.body:getX(), o.planet.body:getY(), player.body:getX(), player.body:getY()) < o.planet.size/2 + 1000 then
        local angle = planet_player_angle(o.planet) % (2*math.pi)
        local textOffsetX = 0
        local textOffsetY = 0
        local lineOffsetX = 0
        local lineOffsetY = 0

        if angle > 4.18879 and angle < 5.23599 then
          --player is above the planet, draw text below
          textOffsetX = -150
          textOffsetY = 150
          lineOffsetX = 0
          lineOffsetY = 210
        elseif angle > 2.0944 and angle < 4.18879 then
          -- player is left of planet, draw line from right
          textOffsetX = -150
          textOffsetY = -150
          lineOffsetX = 100
          lineOffsetY = -120
        elseif angle > 1.0472 and angle < 2.0944 then
          --player is below the planet, draw line from above
          textOffsetX = -150
          textOffsetY = -150
          lineOffsetX = 0
          lineOffsetY = -160
        else
          --player is to the right of the planet, draw line from left
          textOffsetX = -150
          textOffsetY = -150
          lineOffsetX = -100
          lineOffsetY = -120
        end
        
        love.graphics.setFont(fontMd)
        love.graphics.printf(
          'Resources: ' .. math.floor(o.planet.res) .. '\n Harvested: ' .. math.floor(o.planet.harvestedRes),
          player.body:getX() + textOffsetX,
          player.body:getY() + textOffsetY,
          300,
          'center'
        )

        love.graphics.line(o.planet.body:getX(), o.planet.body:getY(), player.body:getX() + lineOffsetX, player.body:getY() + lineOffsetY)
      end

      drawMoons(o.planet)
    end
  end
end

function drawMoons(planet)
  for i,o in ipairs(planet.orbits) do  
    if o.moon then
      if planet.discovered == true or o.moon.discovered == true then
        love.graphics.setColor(1,1,1,0.3)
        love.graphics.circle('line', planet.body:getX(), planet.body:getY(), distanceBetween(planet.body:getX(), planet.body:getY(), o.moon.body:getX(), o.moon.body:getY()))
        love.graphics.setColor(1,1,1)
      end
      
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

      if distanceBetween(o.moon.body:getX(), o.moon.body:getY(), player.body:getX(), player.body:getY()) < o.moon.size/2 + 1000 then
        love.graphics.setFont(fontMd)
        love.graphics.printf(
          'Resources: ' .. math.floor(o.moon.res) .. '\n Harvested: ' .. math.floor(o.moon.harvestedRes),
          player.body:getX() - 150,
          player.body:getY() - 200,
          300,
          'center'
        )

        love.graphics.line(o.moon.body:getX(), o.moon.body:getY(), player.body:getX() - 100, player.body:getY() - 180)
      end
    end
  end
end