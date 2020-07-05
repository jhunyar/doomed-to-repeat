function spawnSolarSystem(x, y, size)
  star = {}
  star.orbits = {}

  star.size = size
  star.body = love.physics.newBody(myWorld, x, y, 'static')
  star.shape = love.physics.newCircleShape(size/2)
  star.fixture = love.physics.newFixture(star.body, star.shape)
   
  star.body:setMass(size)

  minOrbitRadius = star.size/2 + 50000 -- not too close to the star as it will eventually kill the player
  maxOrbitRadius = mapw/2 - star.size/2 - 20000 -- assuming the star is always at the center of the map here
  maxOrbits = 20
  orbitSeparation = (maxOrbitRadius - minOrbitRadius) / maxOrbits -- assuming 420000/20 = 21,000

  --    55000           475000          21000 should yield 21 orbits?
  for i=minOrbitRadius, maxOrbitRadius, orbitSeparation do
    orbit = {}

    orbit.radius = i
    orbit.speed = love.math.random(50, 100)
    orbit.hasPlanet = love.math.random(0, 1)

    if orbit.hasPlanet == 1 then
      orbit.planet = {}
      orbit.planet.size = love.math.random(2500, 5000)
      orbit.planet.angle = math.rad(love.math.random(0, 360))
      orbit.planet.discovered = false
      orbit.planet.owner = 'none'

      pX = star.body:getX() + orbit.radius * math.cos(orbit.planet.angle)
      pY = star.body:getY() + orbit.radius * math.sin(orbit.planet.angle)

      orbit.planet.body = love.physics.newBody(myWorld, pX, pY, 'static')
      orbit.planet.shape = love.physics.newCircleShape(orbit.planet.size/2)
      orbit.planet.fixture = love.physics.newFixture(orbit.planet.body, orbit.planet.shape)
    end

    table.insert(star.orbits, orbit)
  end
end

-- Every dt, we need to update the positon of planets and moons in the solar system
function updatePlanets(dt)
  for i,o in ipairs(star.orbits) do
    if o.planet then
      -- gravityWell(o.planet.body, star.body:getX(), star.body:getY(), star.size*1000, star.size)
      -- local a = o.planet.angle
      -- o.planet.body:setX(o.planet.body:getX() + math.cos(a)*o.radius)
      -- o.planet.body:setY(o.planet.body:getY() + math.sin(a)*o.radius)

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
      

      if player.landed == true and distanceBetween(o.planet.body:getX(), o.planet.body:getY(), player.body:getX(), player.body:getY()) < o.planet.size/2 + 100 then
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
    end
  end
end


-- function updateMoons()

-- end

-- every dt, we need to draw the planets
function drawPlanets()
  love.graphics.setColor(1, 1, 0)
  love.graphics.circle('fill', star.body:getX(), star.body:getY(), star.size/2)
  love.graphics.setColor(1, 1, 1)

  for i,o in ipairs(star.orbits) do  
    if o.planet then
      love.graphics.draw(sprites.planetLg, o.planet.body:getX(), o.planet.body:getY(), nil, o.planet.size/sprites.planetLg:getWidth(), o.planet.size/sprites.planetLg:getWidth(), sprites.planetLg:getWidth()/2, sprites.planetLg:getHeight()/2)

      if o.planet.owner == 'player' then
        love.graphics.setColor(0,0.2,1)
        love.graphics.rectangle( 'fill', o.planet.body:getX()-100, o.planet.body:getY()-100, 200, 200 )
        love.graphics.setColor(1,1,1)
      elseif o.planet.owner == 'enemy' then
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle( 'fill', o.planet.body:getX()-100, o.planet.body:getY()-100, 200, 200 )
        love.graphics.setColor(1,1,1)
      end
    end
  end
end