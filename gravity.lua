-- get vector
vx = star.position.x - planet.position.x
vy = star.position.y - planet.position.y

-- get distance
dist = math.sqrt(vx^2 + vy^2)

-- gravitation force
force = (G*planetMass*starMass)/dist^2
--[[
  If you assume that G = 6.673 x 10^-11 N m^2/kg^2
  then make sure "dist" is in meters and "mass" is in kg.
]]

-- apply force
force = mass*acceleration
-- so --
acceleration1 = force/planetMass
acceleration2 = force/starMass

-- normalizy vx, vy
nx, ny = 0, 0
if dist > 0 then 
  nx, ny = vx/dist, vy/dist
end

-- multiply normalized vector by direction
acceleration1x = nx*acceleration1 
acceleration1y = ny*acceleration1 

-- add the change in velocity (acceleration*dt) to the current velocity of each object.
planet.velocity.x = planet.velocity.x + acceleration1x*dt
planet.velocity.y = planet.velocity.y + acceleration1y*dt