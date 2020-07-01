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