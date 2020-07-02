function distanceBetween(x1, y1, x2, y2)
  return math.sqrt((y2 -y1)^2 + (x2 - x1)^2)
end

function player_mouse_angle()
  x,y = cam:mousePosition()
  return math.atan2(player.body:getY() - y, player.body:getX() - x) + math.pi
end

function enemy_player_angle(enemy)
  return math.atan2(player.body:getY() - enemy.y, player.body:getX() - enemy.x)
end

function enemy_waypoint_angle(e)
  return math.atan2(e.wy - e.y, e.wx - e.x)
end

function getAngle(a, b)
  return math.atan2(b.y - a.y, b.x - a.x)
end

function clamp(x, y, d)
  local d2 = math.sqrt(x*x + y*y)
  if d2 > d then
    x = x/d2*d
    y = y/d2*d
  end
  return x, y, d2
end

function gravityWell(body, x, y, power, epsilon)
  local lx = x - body:getX()  -- vector x
  local ly = y - body:getY()  -- vector y
  local ldSq = lx^2 + ly^2    -- direction

  power = power * 10000 or 100000
  epsilon = epsilon * epsilon or 50 * 50

  if ldSq ~= 0 then
    local ld = math.sqrt(ldSq)
    -- removing the below code makes the gravity the same on all planets
    -- if ldSq < epsilon then
    --   ldSq = epsilon
    -- end
      
    local lfactor = (power * love.timer.getDelta()) / (ldSq * ld)
    local oldX, oldY = body:getLinearVelocity()
    body:setLinearVelocity(oldX + lx * lfactor, oldY + ly * lfactor)
  end
end

function radToDeg(r)
  deg = r*180/math.pi
  return deg
end